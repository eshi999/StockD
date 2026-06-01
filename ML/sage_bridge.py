# sage_bridge.py — SAGE ML bridge for FastAPI (100% On-The-Fly Data Engine)
import sys
from pathlib import Path
from typing import Optional

import numpy as np
import pandas as pd
import yfinance as yf


def _get_runtime_dir() -> Path:
    exe = Path(sys.executable).resolve()
    exe_dir = exe.parent
    # In a Nuitka binary, the executable sits next to the model files
    if (exe_dir / "sage_model.keras").exists() or (exe_dir / "artifacts").exists():
        return exe_dir
    # Fallback for dev mode — use the script's own directory
    return Path(__file__).resolve().parent


# ── Helpers ───────────────────────────────────────────────────────────────────


def safe_float(val, default: float = 0.0) -> float:
    try:
        if hasattr(val, "item"):
            val = val.item()
        v = float(val)
        return v if v == v else default
    except Exception:
        return default


def safe_int(val, default: int = 0) -> int:
    v = safe_float(val, float("nan"))
    return int(v) if v == v else default


def safe_round(val, digits: int = 2, default: float = 0.0) -> float:
    v = safe_float(val, float("nan"))
    if v != v:
        return default
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
    df["Volatility_20"] = (
        df["Daily_Return"].rolling(window=20, min_periods=1).std().fillna(0.0)
    )

    return df


def _fetch_live_dataframe(ticker: str, period: str = "2y") -> pd.DataFrame:
    try:
        clean_symbol = ticker.strip().upper()
        df = yf.download(clean_symbol, period=period, auto_adjust=True, progress=False)

        if df.empty:
            return pd.DataFrame()

        if isinstance(df.columns, pd.MultiIndex):
            df.columns = df.columns.get_level_values(0)

        df = df.reset_index()
        df = _compute_technical_indicators(df)
        return df
    except Exception as e:
        print(f"[SAGE] Direct API fetch warning for {ticker}: {e}")
        return pd.DataFrame()


# ── Model Loading ─────────────────────────────────────────────────────────────


def load_model() -> bool:
    global _model, _scaler, _calibrator
    import os

    if sys.platform != "darwin":
        os.environ.setdefault("TF_FORCE_GPU_ALLOW_GROWTH", "true")

    try:
        from artifacts import load_pickle

        scaler_path = ML_DIR / SCALER_PATH
        _scaler = load_pickle(str(scaler_path)) if scaler_path.exists() else None
    except Exception:
        _scaler = None

    if _scaler is None:
        try:
            from scalers import IdentityScaler

            _scaler = IdentityScaler()
        except Exception:
            _scaler = None

    try:
        from artifacts import load_pickle

        calib_path = ML_DIR / CALIBRATION_PATH
        if calib_path.exists():
            _calibrator = load_pickle(str(calib_path))
            print(f"[SAGE] Calibrator loaded from {calib_path}")
        else:
            _calibrator = None
    except Exception:
        _calibrator = None

    try:
        import tensorflow as tf
    except ImportError:
        _model = None
        return False

    candidates = [
        ML_DIR / "sage_model.keras",
        ML_DIR / "artifacts" / "sage_model_best.keras",
        ML_DIR / "artifacts" / "sage_model.keras",
    ]
    for path in candidates:
        if path.exists():
            try:
                _model = tf.keras.models.load_model(str(path))
                print(f"[SAGE] Model loaded from {path}")
                return True
            except Exception as e:
                print(f"[SAGE] Failed to load {path}: {e}")
                continue

    _model = None
    return False


# ── Market Snapshot ───────────────────────────────────────────────────────────


def get_market_snapshot() -> list:
    core_anchors = [
        "SPY", "AAPL", "MSFT", "GOOGL", "AMZN",
        "NVDA", "META", "TSLA", "JPM", "V",
    ]
    results = []

    try:
        batch_df = yf.download(
            core_anchors, period="5d", auto_adjust=True, progress=False
        )
        if batch_df.empty:
            return []

        for ticker in core_anchors:
            try:
                if isinstance(batch_df.columns, pd.MultiIndex):
                    close_series = batch_df["Close"][ticker].dropna()
                else:
                    close_series = batch_df["Close"].dropna()

                if len(close_series) < 2:
                    continue

                price = float(close_series.iloc[-1])
                prev_close = float(close_series.iloc[-2])
                pct = ((price - prev_close) / prev_close) * 100.0

                sign = "+" if pct >= 0 else ""
                results.append(
                    {
                        "ticker": ticker,
                        "change": f"{sign}{pct:.2f}%",
                        "up": bool(pct >= 0),
                        "sector": "S&P 500 Index Component"
                        if ticker == "SPY"
                        else "Market Leader",
                    }
                )
            except Exception:
                continue
    except Exception as e:
        print(f"[SAGE] Snapshot batch assembly failure: {e}")
        return []

    results.sort(
        key=lambda x: abs(safe_float(x["change"].replace("%", "").replace("+", ""))),
        reverse=True,
    )
    return results


# ── Stock History ─────────────────────────────────────────────────────────────


def get_stock_history(ticker: str, timeframe: str = "1Y") -> dict:
    df = _fetch_live_dataframe(ticker, period="2y")
    if df.empty:
        return {"error": "no_local_data"}

    n_rows = {"1D": 2, "1W": 5, "1M": 21, "3M": 63, "1Y": 252}.get(timeframe, 252)

    df_slice = df.tail(n_rows).reset_index(drop=True)
    df_1y = df.tail(252)

    closes = [safe_float(v) for v in df_slice["Close"]]
    opens = [safe_float(v) for v in df_slice["Open"]]
    highs = [safe_float(v) for v in df_slice["High"]]
    lows = [safe_float(v) for v in df_slice["Low"]]
    volumes = [safe_int(v) for v in df_slice["Volume"]]
    rsis = [safe_float(v) for v in df_slice["RSI_14"]]
    sma50s = [safe_float(v) for v in df_slice["SMA_50"]]
    sma200s = [safe_float(v) for v in df_slice["SMA_200"]]
    daily_ret = [safe_float(v) for v in df_slice["Daily_Return"]]
    dates = [str(d)[:10] for d in df_slice["Date"]]

    last = df.iloc[-1]
    prev = df.iloc[-2] if len(df) >= 2 else last

    price = safe_float(last["Close"])
    prev_close = safe_float(prev["Close"])
    daily_return_pct = ((price - prev_close) / prev_close * 100) if prev_close else 0.0
    high_52w = safe_float(df_1y["High"].max())
    low_52w = safe_float(df_1y["Low"].min())
    avg_vol = safe_int(df_1y["Volume"].mean() if "Volume" in df_1y.columns else 0)

    company_name = ticker
    sector = "Public Equities Market Asset"
    industry = "Global Exchange Tracked"

    rsi = safe_float(last["RSI_14"])
    sma_50 = safe_float(last["SMA_50"])
    sma_200 = safe_float(last["SMA_200"])
    vol20 = safe_float(last["Volatility_20"])
    ann_vol = safe_round(vol20 * (252**0.5) * 100, 1)

    return {
        "ticker": ticker,
        "company_name": company_name,
        "sector": sector,
        "industry": industry,
        "price": safe_round(price, 2),
        "prev_close": safe_round(prev_close, 2),
        "daily_return": safe_round(daily_return_pct, 2),
        "high_52w": safe_round(high_52w, 2),
        "low_52w": safe_round(low_52w, 2),
        "avg_volume": avg_vol,
        "rsi": safe_round(rsi, 1),
        "sma_50": safe_round(sma_50, 2),
        "sma_200": safe_round(sma_200, 2),
        "volatility_ann": ann_vol,
        "dates": dates,
        "closes": closes,
        "opens": opens,
        "highs": highs,
        "lows": lows,
        "volumes": volumes,
        "rsi_series": rsis,
        "sma50_series": sma50s,
        "sma200_series": sma200s,
        "daily_ret_series": daily_ret,
    }


# ── Internal Prediction ───────────────────────────────────────────────────────


def _run_model(ticker: str) -> dict:
    if _model is None:
        return {"error": "model_not_loaded"}

    df = _fetch_live_dataframe(ticker, period="2y")
    if df.empty or len(df) < WINDOW_SIZE:
        return {"error": "insufficient_data"}

    df = df.dropna(subset=FEATURE_COLS)
    if len(df) < WINDOW_SIZE:
        return {"error": "insufficient_data"}

    raw_features = df[FEATURE_COLS].astype("float32").values
    scaled = _scaler.transform(raw_features) if _scaler is not None else raw_features
    seq = np.expand_dims(np.asarray(scaled[-WINDOW_SIZE:], dtype="float32"), axis=0)

    outputs = _model.predict(seq, verbose=0)

    if hasattr(outputs, "flatten"):
        raw_prob = float(outputs.flatten()[0])
    else:
        raw_prob = float(outputs[0])

    if _calibrator is not None:
        try:
            prob = float(
                _calibrator.predict_proba(np.array([[raw_prob]], dtype="float32"))[0][1]
            )
        except Exception:
            prob = raw_prob
    else:
        prob = raw_prob

    close = safe_float(df["Close"].iloc[-1])
    prev_close = safe_float(df["Close"].iloc[-2]) if len(df) > 1 else close
    momentum = safe_float(df["Daily_Return"].iloc[-5:].mean()) * 100
    vol20 = safe_float(df["Volatility_20"].iloc[-1])

    return {
        "confidence": safe_round(prob * 100, 1),
        "rsi": safe_round(df["RSI_14"].iloc[-1], 1),
        "momentum": safe_round(momentum, 2),
        "sma_50": safe_round(df["SMA_50"].iloc[-1], 2),
        "sma_200": safe_round(df["SMA_200"].iloc[-1], 2),
        "volatility_20": safe_round(vol20 * np.sqrt(252) * 100, 1),
        "price": safe_round(close, 2),
        "prev_close": safe_round(prev_close, 2),
    }


# ── SAGE Explain ──────────────────────────────────────────────────────────────


def explain_question(
    question_id: str,
    concept: str,
    prompt: str,
    user_answer: str,
    correct_answer: str,
    chart_symbol: Optional[str] = None,
) -> dict:
    symbol = chart_symbol or "SPY"
    history = get_stock_history(symbol, timeframe="3M")
    model = _run_model(symbol)

    chart_data = []
    if "error" not in history:
        chart_data = [
            {"date": d, "close": c} for d, c in zip(history["dates"], history["closes"])
        ]

    rsi = model.get("rsi", 0)
    sma50 = model.get("sma_50", 0)
    sma200 = model.get("sma_200", 0)
    mom = model.get("momentum", 0)
    vol = model.get("volatility_20", 0)

    explanation = f"""You answered: {user_answer}
Correct answer: {correct_answer}

── Concept: {concept} ──

{prompt}

── {symbol} Market Data ──

- RSI (14):            {rsi}
- SMA 50:              ${sma50}
- SMA 200:             ${sma200}
- Momentum (5d):       {mom:+.2f}%
- Annualized Vol:      {vol:.1f}%

Understanding {concept} in the context of real market data
helps you recognise these patterns when you see them.
Study the chart to see how price, momentum and volatility
interact over time.

⚠️ This is educational content only, not financial advice."""

    return {
        "explanation": explanation,
        "chart_title": f"{symbol} — 3 Month Price History",
        "chart_data": chart_data,
    }


# ── SAGE Chat ─────────────────────────────────────────────────────────────────


def chat(message: str, history: list[dict]) -> str:
    msg_lower = message.lower().strip()
    words = message.upper().split()

    ticker_data = None
    found_ticker = None

    for word in words:
        clean = word.strip("?.,!()\"'")
        if 1 <= len(clean) <= 5 and clean.isalpha():
            test_data = get_stock_history(clean, timeframe="1M")
            if "error" not in test_data:
                found_ticker = clean
                ticker_data = test_data
                break

    if found_ticker and ticker_data and "error" not in ticker_data:
        t = ticker_data
        price = t.get("price", 0)
        rsi = t.get("rsi", 0)
        sma50 = t.get("sma_50", 0)
        sma200 = t.get("sma_200", 0)
        vol = t.get("volatility_ann", 0)
        ret = t.get("daily_return", 0)
        h52 = t.get("high_52w", 0)
        l52 = t.get("low_52w", 0)
        name = t.get("company_name", found_ticker)
        sector = t.get("sector", "N/A")

        if "rsi" in msg_lower:
            condition = (
                "overbought territory (above 70)"
                if rsi > 70
                else "oversold territory (below 30)"
                if rsi < 30
                else "neutral territory (30–70)"
            )
            return (
                f"{found_ticker}'s RSI is {rsi:.1f} — {condition}.\n\n"
                f"RSI measures the speed and magnitude of recent price changes "
                f"on a 0–100 scale. Above 70 is considered overbought, below 30 "
                f"oversold. Neither guarantees a price reversal.\n\n"
                f"⚠️ Educational information only, not financial advice."
            )

        if any(w in msg_lower for w in ["volatil", "risk", "stable", "swing"]):
            level = "high" if vol > 40 else "moderate" if vol > 20 else "low"
            return (
                f"{found_ticker} has an annualized volatility of {vol:.1f}% — "
                f"considered {level}.\n\n"
                f"Volatility measures how much a stock's price fluctuates. "
                f"Higher volatility means larger price swings in both directions.\n\n"
                f"⚠️ Educational information only, not financial advice."
            )

        if any(w in msg_lower for w in ["sma", "moving average", "trend", "200", "50"]):
            t50 = "above" if price > sma50 else "below"
            t200 = "above" if price > sma200 else "below"
            return (
                f"{found_ticker} is at ${price:.2f}.\n\n"
                f"• 50-day SMA:  ${sma50:.2f}  — price is {t50} this level\n"
                f"• 200-day SMA: ${sma200:.2f} — price is {t200} this level\n\n"
                f"Moving averages smooth price data to reveal trends. "
                f"The 50 and 200-day SMAs are widely watched reference levels.\n\n"
                f"⚠️ Educational information only, not financial advice."
            )

        if any(w in msg_lower for w in ["52", "high", "low", "range", "year"]):
            pct_from_low = ((price - l52) / l52 * 100) if l52 else 0
            return (
                f"{found_ticker} 52-week range: ${l52:.2f} – ${h52:.2f}\n"
                f"Current price ${price:.2f} is {pct_from_low:.1f}% above the 52-week low.\n\n"
                f"The 52-week range shows the highest and lowest prices over the past year, "
                f"giving context for where the stock is trading relative to recent history.\n\n"
                f"⚠️ Educational information only, not financial advice."
            )

        return (
            f"Here's what I know about {found_ticker} ({name}):\n\n"
            f"• Sector:       {sector}\n"
            f"• Price:        ${price:.2f}\n"
            f"• Daily Return: {ret:+.2f}%\n"
            f"• RSI (14):     {rsi:.1f}\n"
            f"• SMA 50:       ${sma50:.2f}\n"
            f"• SMA 200:      ${sma200:.2f}\n"
            f"• 52W Range:    ${l52:.2f} – ${h52:.2f}\n"
            f"• Ann. Vol:     {vol:.1f}%\n\n"
            f"Ask me about any of these metrics to learn more.\n\n"
            f"⚠️ Educational information only, not financial advice."
        )

    # ── Concept explanations ──────────────────────────────────────────────────
    concepts: dict[str, str] = {
        "p/e": "The Price-to-Earnings (P/E) ratio compares a stock's price to its earnings per share (EPS).",
        "market cap": "Market cap = share price × shares outstanding. Represents total company value.\n• Large-cap: >$10B\n• Mid-cap: $2B–$10B\n• Small-cap: <$2B",
        "dividend": "A dividend is a portion of profits paid to shareholders, usually quarterly.",
        "short selling": "Short selling = borrowing shares, selling them, then buying them back cheaper later.",
        "etf": "An ETF (Exchange-Traded Fund) is a basket of securities trading on an exchange like a stock.",
        "bull market": "A bull market is a sustained period of rising prices (typically 20%+ from lows).",
        "bear market": "A bear market is a sustained period of falling prices (typically 20%+ from highs).",
        "volume": "Trading volume is the number of shares traded in a given timeframe.",
        "rsi": "RSI (Relative Strength Index) is a momentum oscillator measuring price velocity (0-100).",
        "sma": "SMA smooths price metrics by averaging specific calendar blocks (50 and 200 days).",
        "ema": "EMA is a moving average that applies higher weighting multipliers to recent price events.",
        "candlestick": "A candlestick indicates open, high, low, and close coordinates for a defined interval.",
        "support": "Support acts as a price floor where concentrated demand halts declines.",
        "resistance": "Resistance acts as a price ceiling where concentrated supply stalls upward growth.",
        "volatility": "Volatility quantifies tracking variance over fixed standard deviation timelines.",
        "ipo": "An IPO occurs when a company changes from private to open public capital listings.",
        "earnings": "Earnings reveal standard profitability matrices released quarterly by corporations.",
        "liquidity": "Liquidity refers to how smoothly an asset trades without forcing deep spreads.",
        "bid ask": "The bid is the buyers ceiling; the ask is the sellers baseline floor map.",
    }

    for keyword, explanation in concepts.items():
        if keyword in msg_lower:
            return f"**{keyword.upper()}**\n\n{explanation}\n\n⚠️ Educational information only, not financial advice."

    # ── Advice guard ──────────────────────────────────────────────────────────
    advice_words = [
        "buy", "sell", "invest", "should i", "recommend", "worth it", "good stock",
    ]
    if any(w in msg_lower for w in advice_words):
        return (
            "I can't give investment advice or recommend buying or selling any stock.\n\n"
            "What I can do:\n"
            "• Explain what any stock market concept means\n"
            "• Show you historical data for S&P 500 stocks (e.g. type 'AAPL')\n"
            "• Help you understand indicators like RSI, SMA, volatility\n\n"
            "What would you like to learn about?"
        )

    return (
        "I'm SAGE — your stock market education assistant.\n\n"
        "I can help you with:\n"
        "• Stock concepts — P/E, RSI, moving averages, volatility, ETFs...\n"
        "• S&P 500 data — just type a ticker like AAPL, MSFT, TSLA\n"
        "• Chart indicators — candlesticks, support, resistance, volume\n\n"
        "What would you like to learn about?\n\n"
        "⚠️ I provide educational information only, not financial advice."
    )
