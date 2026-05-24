# evaluate_end_user_metrics.py

import os
import json
import numpy as np
import pandas as pd
import tensorflow as tf

from ml_config import *
from artifacts import save_json, load_pickle
from sequence_utils import build_windows


# -----------------------------
# Confidence threshold strategy
# -----------------------------
# Modes:
#   - "fixed": uses HIGH_CONF_BUY / HIGH_CONF_AVOID from ml_config.py
#   - "quantile": chooses thresholds from calibrated probability distribution
#
# You can override via env vars:
#   SAGE_CONF_MODE=quantile
#   SAGE_Q_LOW=0.10
#   SAGE_Q_HIGH=0.90
CONF_MODE = os.getenv("SAGE_CONF_MODE", "fixed").strip().lower()
Q_LOW = float(os.getenv("SAGE_Q_LOW", "0.10"))
Q_HIGH = float(os.getenv("SAGE_Q_HIGH", "0.90"))

# Must match inference.py
MIN_EXPECTED_RETURN = float(os.getenv("SAGE_MIN_EXPECTED_RETURN", "0.002"))

# Eval caps (predictable runtime)
ROWS_PER_TICKER = int(os.getenv("SAGE_EVAL_ROWS_PER_TICKER", "600"))
EVAL_MAX = int(os.getenv("SAGE_EVAL_MAX_WINDOWS", "200000"))
BATCH = int(os.getenv("SAGE_EVAL_BATCH", "8192"))  # lower (4096) if VRAM issues


def load_model_for_eval():
    path = BEST_MODEL_PATH if os.path.exists(BEST_MODEL_PATH) else MODEL_PATH
    if not os.path.exists(path):
        raise FileNotFoundError(
            f"Model not found at '{BEST_MODEL_PATH}' or '{MODEL_PATH}'. Run train_sage.py first."
        )
    return tf.keras.models.load_model(path, compile=False), path


def load_optional(path):
    if not os.path.exists(path):
        return None
    try:
        return load_pickle(path)
    except Exception as e:
        print(f"Warning: failed to load {path}: {e}")
        return None


def pick_thresholds(cal_probs: np.ndarray):
    """
    Returns (buy_thr, avoid_thr, mode_label)
    """
    if CONF_MODE == "quantile":
        # Defensive: clamp and validate
        ql = max(0.0, min(1.0, Q_LOW))
        qh = max(0.0, min(1.0, Q_HIGH))
        if not (0.0 <= ql < 0.5 and 0.5 < qh <= 1.0 and ql < qh):
            raise ValueError(
                f"Invalid quantiles: Q_LOW={Q_LOW}, Q_HIGH={Q_HIGH}. "
                f"Recommended: Q_LOW=0.10 and Q_HIGH=0.90 (or 0.05/0.95)."
            )

        buy_thr = float(np.quantile(cal_probs, qh))
        avoid_thr = float(np.quantile(cal_probs, ql))
        return buy_thr, avoid_thr, f"quantile(q_low={ql}, q_high={qh})"

    # fixed
    return float(HIGH_CONF_BUY), float(HIGH_CONF_AVOID), "fixed"


print("Loading data...")
df = pd.read_csv("sage_training_data.csv")
df["Date"] = pd.to_datetime(df["Date"])
df = df.dropna(subset=FEATURE_COLS + ["Target", "FutureReturn"]).copy()
df.sort_values(["Ticker", "Date"], inplace=True)

baseline = float(df["Target"].mean())

# ---- Thorough-enough evaluation windowing ----
df = df.groupby("Ticker", group_keys=False).tail(ROWS_PER_TICKER)
print(f"Using last {ROWS_PER_TICKER} rows per ticker for evaluation speed.")

print("Building windows for evaluation...")
X, y_class, y_ret, meta = build_windows(df)

n_total = int(len(y_class))
if n_total == 0:
    raise RuntimeError("No windows available for evaluation.")

# Cap total windows evaluated (runtime predictable)
if n_total > EVAL_MAX:
    X = X[-EVAL_MAX:]
    y_class = y_class[-EVAL_MAX:]
    y_ret = y_ret[-EVAL_MAX:]
    meta = meta[-EVAL_MAX:]
    print(f"Evaluating last {EVAL_MAX} windows (thorough cap).")

y_class = np.asarray(y_class).astype(int)
y_ret = np.asarray(y_ret).astype(float)
n = int(len(y_class))

print("Loading model + optional calibrator...")
model, model_used = load_model_for_eval()
calibrator = load_optional(CALIBRATION_PATH)

# Batch inference (GPU-friendly)
raw_probs = np.empty((n,), dtype=np.float32)
exp_rets = np.empty((n,), dtype=np.float32)

print(f"Running batched inference: {n} windows, batch={BATCH} ...")
for i in range(0, n, BATCH):
    xb = X[i:i + BATCH]
    p, r = model.predict(xb, verbose=0)
    raw_probs[i:i + len(xb)] = np.ravel(p).astype(np.float32)
    exp_rets[i:i + len(xb)] = np.ravel(r).astype(np.float32)

# Optional calibration (maps raw -> calibrated probability)
used_calibration = False
if calibrator is not None:
    try:
        cal_probs = calibrator.predict_proba(raw_probs.reshape(-1, 1))[:, 1].astype(np.float32)
        used_calibration = True
    except Exception as e:
        print("Warning: calibration failed, using raw probs:", e)
        cal_probs = raw_probs
else:
    cal_probs = raw_probs

# Choose thresholds (fixed or quantile-based)
buy_thr, avoid_thr, conf_mode_label = pick_thresholds(cal_probs)
print(f"Confidence mode: {conf_mode_label}")
print(f"Thresholds: BUY >= {buy_thr:.6f} | AVOID <= {avoid_thr:.6f}")

# Directional accuracy (p_up >= 0.5 predicts up)
pred_dir = (cal_probs >= 0.5).astype(int)
directional_accuracy = float((pred_dir == y_class).mean())

# High-confidence behavior (end-user relevant)
high_mask = (cal_probs >= buy_thr) | (cal_probs <= avoid_thr)
hc_total = int(high_mask.sum())
coverage = float(hc_total / n)

hc_accuracy = float((pred_dir[high_mask] == y_class[high_mask]).mean()) if hc_total > 0 else None

# ---- Match inference BUY logic exactly ----
buy_mask = (cal_probs >= buy_thr) & (exp_rets >= MIN_EXPECTED_RETURN)
buy_count = int(buy_mask.sum())
avg_realized_return_on_buy = float(y_ret[buy_mask].mean()) if buy_count > 0 else None

# Some helpful distribution stats (for debugging/demo defensibility)
qs = np.quantile(cal_probs, [0.01, 0.05, 0.10, 0.50, 0.90, 0.95, 0.99]).astype(float).tolist()

metrics = {
    "directional_accuracy": directional_accuracy,
    "baseline_accuracy": float(baseline),
    "edge_vs_baseline": float(directional_accuracy - baseline),

    "high_confidence_accuracy": hc_accuracy,
    "high_confidence_coverage": coverage,

    "avg_realized_future_return_on_high_conf_buy": avg_realized_return_on_buy,

    "n_windows_evaluated": int(n),
    "rows_per_ticker_eval": int(ROWS_PER_TICKER),
    "window_size": int(WINDOW_SIZE),
    "horizon_days": int(HORIZON_DAYS),

    "confidence_mode": conf_mode_label,
    "confidence_thresholds": {"buy": float(buy_thr), "avoid": float(avoid_thr)},
    "min_expected_return_for_buy": float(MIN_EXPECTED_RETURN),

    "calibrated_prob_quantiles": {
        "p01": qs[0], "p05": qs[1], "p10": qs[2], "p50": qs[3], "p90": qs[4], "p95": qs[5], "p99": qs[6]
    },

    "used_calibration": bool(used_calibration),
    "model_used": model_used,
}

os.makedirs(ARTIFACT_DIR, exist_ok=True)
save_json(metrics, END_USER_METRICS_PATH)

print("Saved ->", END_USER_METRICS_PATH)
print(json.dumps(metrics, indent=2))
