# sage_bridge.py — SAGE ML bridge for FastAPI (100% On-The-Fly Data Engine)
import sys
import os
import re
import json
import joblib
from pathlib import Path
from typing import Optional
import numpy as np
import pandas as pd
import yfinance as yf
import tensorflow as tf

# 1. Define ML_DIR using __file__ — works correctly with python-build-standalone
ML_DIR = Path(__file__).resolve().parent

# 2. Match the exact matrix constants from your model configuration blueprint
SCALER_PATH = "feature_scaler.joblib"
CALIBRATION_PATH = "calibration.joblib"
MODEL_ARCH_PATH = "sage_model_arch.json"
MODEL_WEIGHTS_PATH = "sage_model_weights.h5"

WINDOW_SIZE = 30
FEATURE_COLS = [
    "Close", "RSI_14", "SMA_50", "SMA_200", "Volatility_20",
    "Open", "High", "Low", "Volume", "Daily_Return"
]

# Global model pointers
_model = None
_scaler = None
_calibrator = None

# ── SAGE Knowledge Base ───────────────────────────────────────────────────────
KNOWLEDGE_BASE = {
    "P/E": "The P/E (Price-to-Earnings) ratio measures a company's current share price relative to its per-share earnings. A high P/E could mean a stock is overvalued, or investors expect high growth.",
    "RSI": "RSI (Relative Strength Index) is a momentum indicator ranging from 0 to 100. Traditionally, a stock is considered overbought above 70 and oversold below 30.",
    "SMA": "SMA (Simple Moving Average) calculates the average of a selected range of prices by the number of periods in that range. It helps smooth out price data to spot trends.",
    "BULL": "A 'Bull' market is a financial market where prices are rising or are expected to rise. Bullish investors are optimistic about the future.",
    "BEAR": "A 'Bear' market is a market in which prices are falling, encouraging selling. Bearish investors are pessimistic about the market's direction.",
    "ETF": "An ETF (Exchange Traded Fund) is a basket of securities that trades on an exchange just like a stock. They often track an index like the S&P 500.",
    "DIVIDEND": "A dividend is a distribution of a portion of a company's earnings, decided by the board of directors, paid to a class of its shareholders.",
    "VOLUME": "Volume is the number of shares traded in a security or an entire market during a given period of time. High volume often confirms a price trend.",
    "SUPPORT": "Support is a price level where a downtrend tends to pause due to a concentration of demand or buying interest.",
    "RESISTANCE": "Resistance is a price level where an uptrend tends to pause temporarily, due to a concentration of supply or selling interest."
}

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

def _extract_ticker(text: str) -> Optional[str]:
    words = text.replace('$', '').replace('?', '').replace('.', '').split()
    for word in words:
        if word.isupper() and 1 <= len(word) <= 5 and word.isalpha():
            if word not in ["WHAT", "IS", "THE", "TELL", "ME", "ABOUT", "HOW", "CHAT", "SAGE"]:
                return word
    return None

# ── Technical Indicator Calculators ──────────────────────────────────────────

def _compute_technical_indicators(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()

    if isinstance(df.columns, pd.MultiIndex):
        df.columns = df.columns.get_level_values(0)

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

    for col in ["Open", "High", "Low", "Volume"]:
        if col in df.columns:
            df[col] = df[col].ffill().bfill().fillna(0.0)

    return df

def _fetch_live_dataframe(ticker: str, period: str = "2y") -> pd.DataFrame:
    try:
        clean_symbol = ticker.strip().upper()
        df = yf.download(clean_symbol, period=period, auto_adjust=True, progress=False)
        if df.empty: return pd.DataFrame()
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

    # Load Scaler via Joblib
    try:
        s_path = ML_DIR / "artifacts" / "feature_scaler.joblib"
        _scaler = joblib.load(str(s_path)) if s_path.exists() else None
    except Exception as e:
        print(f"[SAGE] Scaler load failed: {e}")
        _scaler = None

    # Load Calibrator via Joblib
    try:
        c_path = ML_DIR / "artifacts" / "calibration.joblib"
        _calibrator = joblib.load(str(c_path)) if c_path.exists() else None
    except Exception as e:
        print(f"[SAGE] Calibrator load failed: {e}")
        _calibrator = None

    # Load Model (Architecture + Weights bypasses pickle)
    try:
        # Hardcoding the exact names to prevent path doubling
        arch_path = ML_DIR / "artifacts" / "sage_model_arch.json"
        weights_path = ML_DIR / "artifacts" / "sage_model_weights.weights.h5"
        
        if arch_path.exists() and weights_path.exists():
            with open(arch_path, "r") as f:
                json_str = f.read()
            _model = tf.keras.models.model_from_json(json_str)
            _model.load_weights(str(weights_path))
            print(f"[SAGE] Model loaded securely via JSON/H5 mapping.")
            return True
        else:
            print(f"[SAGE] File not found!")
            print(f"  -> Arch path: {arch_path} (Exists: {arch_path.exists()})")
            print(f"  -> Weights path: {weights_path} (Exists: {weights_path.exists()})")
            return False
            
    except Exception as e:
        print(f"[SAGE] Fatal initialization failure: {e}")
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

    return {
        "ticker": ticker,
        "price": safe_round(safe_float(df.iloc[-1]["Close"]), 2),
        "dates": [str(d)[:10] for d in df_slice["Date"]],
        "closes": [safe_float(v) for v in df_slice["Close"]],
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
    res_p_up = outputs[0]
    res_expected_return = outputs[1]

    raw_prob = float(res_p_up.flatten()[0]) if hasattr(res_p_up, "flatten") else float(res_p_up[0])
    prob = float(_calibrator.predict_proba(np.array([[raw_prob]], dtype="float32"))[0][1]) if _calibrator else raw_prob

    predicted_magnitude = float(res_expected_return.flatten()[0]) if hasattr(res_expected_return, "flatten") else float(res_expected_return[0])

    current_rsi = safe_round(safe_float(df["RSI_14"].iloc[-1]), 1)
    current_price = safe_round(safe_float(df["Close"].iloc[-1]), 2)

    return {
        "confidence": safe_round(prob * 100, 1),
        "expected_return": safe_round(predicted_magnitude * 100, 2),
        "price": current_price,
        "rsi": current_rsi
    }

# ── SAGE Explain ──────────────────────────────────────────────────────────────

def explain_question(question_id: str, concept: str, prompt: str, user_answer: str, correct_answer: str, chart_symbol: Optional[str] = None) -> dict:
    is_correct = str(user_answer).strip().lower() == str(correct_answer).strip().lower()

    if is_correct:
        explanation = f"Correct! Your answer '{user_answer}' is accurate. "
    else:
        explanation = f"Not quite. The correct answer was '{correct_answer}'. "

    concept_upper = str(concept).upper()
    if concept_upper in KNOWLEDGE_BASE:
        explanation += f"Context: {KNOWLEDGE_BASE[concept_upper]}"
    else:
        explanation += "This parameter serves as an analytical benchmark for system modeling."

    chart_data = []
    if chart_symbol:
        hist = get_stock_history(chart_symbol, timeframe="1M")
        if "error" not in hist:
            explanation += f"\n\nReference the trailing 30-day historical window for {chart_symbol.upper()} below."
            chart_data = hist["closes"]

    return {
        "explanation": explanation,
        "chart_data": chart_data
    }

# ── SAGE Chat ─────────────────────────────────────────────────────────────────

def chat(message: str, history: list[dict]) -> str:
    msg_upper = message.strip().upper()

    if _model is None:
        return "The local SAGE predictive core is offline or processing assets. Re-evaluating system layout..."

    for key, definition in KNOWLEDGE_BASE.items():
        if key in msg_upper:
            return definition

    target_ticker = _extract_ticker(msg_upper)
    if target_ticker:
        prediction = _run_model(target_ticker)
        if "error" in prediction:
            return f"I pulled metrics for {target_ticker}, but trade volume historical length is insufficient for functional sequence modeling."

        conf = prediction['confidence']
        price = prediction['price']
        rsi = prediction['rsi']
        expected_ret = prediction['expected_return']

        if conf >= 65:
            sentiment = f"strong upward structural trends, matching an expected return target near {expected_ret}%"
        elif conf >= 50:
            sentiment = f"a modest bullish configuration tracking toward a {expected_ret}% magnitude move"
        elif conf >= 35:
            sentiment = f"minor distribution patterns with an estimated downside variance of {expected_ret}%"
        else:
            sentiment = f"sustained overhead resistance causing downward structural pressure near {expected_ret}%"

        if rsi > 70:
            rsi_note = f"Note that the asset's trailing RSI is overbought at {rsi}, introducing technical mean-reversion risk."
        elif rsi < 30:
            rsi_note = f"The asset is technical oversold on the daily chart ({rsi}), which historically implies exhaustion of sell volume."
        else:
            rsi_note = f"The trailing RSI is stabilized in a neutral zone at {rsi}."

        return (f"SAGE Evaluation for {target_ticker} (Last Close: ${price}): The sequence model maps a {conf}% probability of positive directional change over the coming term. "
                f"The tensor layers capture {sentiment}. {rsi_note}")

    return "I am SAGE, your on-the-fly analytical companion. Inquire about an asset (e.g., 'TSLA') or request structural tracking definitions (e.g., 'What is RSI?')."
