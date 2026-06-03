# sage_bridge.py — SAGE ML bridge for FastAPI (100% On-The-Fly Data Engine)
import sys
import os
from pathlib import Path
from typing import Optional
import numpy as np
import pandas as pd
import yfinance as yf

# 1. Define ML_DIR using the environment variable (injected by launcher script)
ML_DIR = Path(os.environ.get("ML_DIR", Path(__file__).resolve().parent))

# 2. Match the constants to your actual file names from your artifacts folder
SCALER_PATH = "feature_scaler.pkl"
CALIBRATION_PATH = "calibration.pkl"
WINDOW_SIZE = 60
FEATURE_COLS = ["Close", "RSI_14", "SMA_50", "SMA_200", "Volatility_20"]

# Global model pointers
_model = None
_scaler = None
_calibrator = None

# ── Helpers ───────────────────────────────────────────────────────────────────

def safe_float(val, default: float = 0.0) -> float:
    try:
        if hasattr(val, "item"): val = val.item()
        v = float(val)
        return v if v == v else default
    except Exception: return default

def safe_int(val, default: int = 0) -> int:
    v = safe_float(val, float("nan"))
    return int(v) if v == v else default

def safe_round(val, digits: int = 2, default: float = 0.0) -> float:
    v = safe_float(val, float("nan"))
    if v != v: return default
    return round(v, digits)

# ── Technical Indicator Calculators ──────────────────────────────────────────

def _compute_technical_indicators(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["SMA_50"] = df["Close"].rolling(window=50, min_periods=1).mean()
    df["SMA_200"] = df["Close"].rolling(window=200, min_periods=1).mean()
    delta = df["Close"].diff()
    gain = delta.clip(lower=0).rolling(window=14, min_periods=1).mean()
    loss = (-delta.clip(upper=0)).rolling(window=14, min_periods=1).mean()
    rs = gain / (loss + 1e-9)
    df["RSI_14"] = 100 - (100 / (1 + rs))
    df["RSI_14"] = df["RSI_14"].fillna(50.0)
    df["Daily_Return"] = df["Close"].pct_change().fillna(0.0)
    df["Volatility_20"] = df["Daily_Return"].rolling(window=20, min_periods=1).std().fillna(0.0)
    return df

def _fetch_live_dataframe(ticker: str, period: str = "2y") -> pd.DataFrame:
    try:
        clean_symbol = ticker.strip().upper()
        df = yf.download(clean_symbol, period=period, auto_adjust=True, progress=False)
        if df.empty: return pd.DataFrame()
        if isinstance(df.columns, pd.MultiIndex): df.columns = df.columns.get_level_values(0)
        df = df.reset_index()
        df = _compute_technical_indicators(df)
        return df
    except Exception as e:
        print(f"[SAGE] Direct API fetch warning for {ticker}: {e}")
        return pd.DataFrame()

# ── Model Loading ─────────────────────────────────────────────────────────────

def load_model() -> bool:
    global _model, _scaler, _calibrator
    if sys.platform != "darwin":
        os.environ.setdefault("TF_FORCE_GPU_ALLOW_GROWTH", "true")
    
    try:
        from artifacts import load_pickle
        s_path = ML_DIR / SCALER_PATH
        _scaler = load_pickle(str(s_path)) if s_path.exists() else None
    except Exception: _scaler = None
    
    try:
        from artifacts import load_pickle
        c_path = ML_DIR / CALIBRATION_PATH
        _calibrator = load_pickle(str(c_path)) if c_path.exists() else None
    except Exception: _calibrator = None

    try:
        import tensorflow as tf
    except ImportError: return False

    for m_file in ["sage_model.keras", "sage_model_best.keras"]:
        m_path = ML_DIR / m_file
        if m_path.exists():
            try:
                _model = tf.keras.models.load_model(str(m_path))
                print(f"[SAGE] Model loaded from {m_path}")
                return True
            except Exception as e: print(f"[SAGE] Load error {m_path}: {e}")
    return False

# ── Market Snapshot ───────────────────────────────────────────────────────────

def get_market_snapshot() -> list:
    core_anchors = ["SPY", "AAPL", "MSFT", "GOOGL", "AMZN", "NVDA", "META", "TSLA", "JPM", "V"]
    results = []
    try:
        batch_df = yf.download(core_anchors, period="5d", auto_adjust=True, progress=False)
        if batch_df.empty: return []
        for ticker in core_anchors:
            try:
                if isinstance(batch_df.columns, pd.MultiIndex): close_series = batch_df["Close"][ticker].dropna()
                else: close_series = batch_df["Close"].dropna()
                if len(close_series) < 2: continue
                price = float(close_series.iloc[-1])
                prev_close = float(close_series.iloc[-2])
                pct = ((price - prev_close) / prev_close) * 100.0
                sign = "+" if pct >= 0 else ""
                results.append({"ticker": ticker, "change": f"{sign}{pct:.2f}%", "up": bool(pct >= 0), "sector": "Market Leader"})
            except Exception: continue
    except Exception as e:
        print(f"[SAGE] Snapshot batch assembly failure: {e}")
        return []
    results.sort(key=lambda x: abs(safe_float(x["change"].replace("%", "").replace("+", ""))), reverse=True)
    return results

# ── Stock History ─────────────────────────────────────────────────────────────

def get_stock_history(ticker: str, timeframe: str = "1Y") -> dict:
    df = _fetch_live_dataframe(ticker, period="2y")
    if df.empty: return {"error": "no_local_data"}
    n_rows = {"1D": 2, "1W": 5, "1M": 21, "3M": 63, "1Y": 252}.get(timeframe, 252)
    df_slice = df.tail(n_rows).reset_index(drop=True)
    df_1y = df.tail(252)
    
    return {
        "ticker": ticker,
        "price": safe_round(safe_float(df.iloc[-1]["Close"]), 2),
        "dates": [str(d)[:10] for d in df_slice["Date"]],
        "closes": [safe_float(v) for v in df_slice["Close"]],
        # (Include your other series here: opens, highs, lows, etc)
    }

# ── Internal Prediction ───────────────────────────────────────────────────────

def _run_model(ticker: str) -> dict:
    if _model is None: return {"error": "model_not_loaded"}
    df = _fetch_live_dataframe(ticker, period="2y")
    if df.empty or len(df) < WINDOW_SIZE: return {"error": "insufficient_data"}
    raw_features = df[FEATURE_COLS].astype("float32").values
    scaled = _scaler.transform(raw_features) if _scaler is not None else raw_features
    seq = np.expand_dims(np.asarray(scaled[-WINDOW_SIZE:], dtype="float32"), axis=0)
    outputs = _model.predict(seq, verbose=0)
    raw_prob = float(outputs.flatten()[0]) if hasattr(outputs, "flatten") else float(outputs[0])
    prob = float(_calibrator.predict_proba(np.array([[raw_prob]], dtype="float32"))[0][1]) if _calibrator else raw_prob
    return {"confidence": safe_round(prob * 100, 1), "price": safe_round(safe_float(df["Close"].iloc[-1]), 2)}

# ── SAGE Explain ──────────────────────────────────────────────────────────────

def explain_question(question_id: str, concept: str, prompt: str, user_answer: str, correct_answer: str, chart_symbol: Optional[str] = None) -> dict:
    symbol = chart_symbol or "SPY"
    # Placeholder implementation
    return {"explanation": "Explanation for concept...", "chart_data": []}

# ── SAGE Chat ─────────────────────────────────────────────────────────────────

def chat(message: str, history: list[dict]) -> str:
    return "SAGE AI initialized."
