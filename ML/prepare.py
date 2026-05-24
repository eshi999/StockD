# prepare.py

import os
from pathlib import Path

import pandas as pd
from artifacts import save_json, save_pickle
from ml_config import (
    ARTIFACT_DIR,
    FEATURE_COLS,
    HORIZON_DAYS,
    METADATA_PATH,
    SCALER_PATH,
    WINDOW_SIZE,
)
from scalers import IdentityScaler

BASE_DIR = Path(__file__).parent.resolve()
DATASET_PATH = BASE_DIR / "sage_training_data.csv"

print("Loading dataset...")
df = pd.read_csv(DATASET_PATH)

if "Date" not in df.columns or "Ticker" not in df.columns:
    raise ValueError("Dataset must include Date and Ticker columns.")

df["Date"] = pd.to_datetime(df["Date"])
df.sort_values(["Ticker", "Date"], inplace=True)

# Ensure required feature columns exist
missing_feats = [c for c in FEATURE_COLS if c not in df.columns]
if missing_feats:
    raise ValueError(f"Missing feature columns in dataset: {missing_feats}")

# Compute FutureReturn/Target if missing
if "FutureReturn" not in df.columns:
    print("Computing FutureReturn...")
    df["FutureReturn"] = (
        df.groupby("Ticker")["Close"].shift(-HORIZON_DAYS) / df["Close"] - 1
    )

if "Target" not in df.columns:
    print("Computing Target from FutureReturn...")
    df["Target"] = (df["FutureReturn"] > 0).astype(int)

# Drop unusable rows (NaNs in features or targets)
df = df.dropna(subset=FEATURE_COLS + ["Target", "FutureReturn"]).reset_index(drop=True)

os.makedirs(ARTIFACT_DIR, exist_ok=True)

# Save IdentityScaler (now pickles as scalers.IdentityScaler, so it loads everywhere)
save_pickle(IdentityScaler(), SCALER_PATH)

ticker_series = pd.Series(df["Ticker"], dtype="string")
ticker_count = int(ticker_series.nunique())

target_series = pd.Series(pd.to_numeric(df["Target"], errors="coerce"), dtype="float64")
baseline_up_rate = float(target_series.mean())

metadata = {
    "rows": len(df),
    "tickers": ticker_count,
    "date_min": str(df["Date"].min()),
    "date_max": str(df["Date"].max()),
    "baseline_up_rate": baseline_up_rate
    if baseline_up_rate == baseline_up_rate
    else 0.0,
    "window_size": WINDOW_SIZE,
    "horizon_days": HORIZON_DAYS,
    "note": "Data appears pre-scaled; using IdentityScaler to keep pipeline consistent.",
}
save_json(metadata, METADATA_PATH)

df.to_csv(DATASET_PATH, index=False)

print("Preparation complete.")
print(
    "Rows:",
    len(df),
    "Tickers:",
    df["Ticker"].nunique(),
    "Baseline:",
    df["Target"].mean(),
)
print("Saved:", METADATA_PATH, "and", SCALER_PATH)
