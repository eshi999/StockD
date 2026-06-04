# inference.py — Standalone inference script for SAGE model
# Usage:
#   python inference.py AAPL
#   python inference.py AAPL MSFT NVDA TSLA
#   python inference.py --top 10

import argparse
import sys
from pathlib import Path

ML_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(ML_DIR))

import numpy as np
import sage_bridge as sage
from ml_config import CALIBRATION_PATH, WINDOW_SIZE

# ── Calibration ───────────────────────────────────────────────────────────────

_calibrator = None


def load_calibrator() -> bool:
    global _calibrator
    calib_path = ML_DIR / CALIBRATION_PATH
    if not calib_path.exists():
        print(
            f"[INFERENCE] No calibrator found at {calib_path} — using raw probabilities."
        )
        return False
    try:
        from artifacts import load_pickle

        _calibrator = load_pickle(str(calib_path))
        print(f"[INFERENCE] Calibrator loaded from {calib_path}")
        return True
    except Exception as e:
        print(f"[INFERENCE] Failed to load calibrator: {e}")
        return False


def calibrate_prob(raw_prob: float) -> float:
    if _calibrator is None:
        return raw_prob
    try:
        arr = np.array([[raw_prob]], dtype="float32")
        return float(_calibrator.predict_proba(arr)[0][1])
    except Exception:
        return raw_prob


def safe_round(val: float, digits: int = 1) -> float:
    try:
        return round(float(val), digits)
    except Exception:
        return 0.0


# ── Core Inference ────────────────────────────────────────────────────────────


def predict(ticker: str) -> dict:
    """
    Run full inference for a single ticker using sage._run_model().
    Adds calibrated_confidence on top.
    Note: results are for educational/research use only — not financial advice.
    """
    result = sage._run_model(ticker.upper())
    if "error" in result:
        return {"ticker": ticker, **result}

    raw_prob = result.get("confidence", 0) / 100.0
    cal_prob = calibrate_prob(raw_prob)

    return {
        "ticker": ticker,
        "confidence": result.get("confidence", 0),
        "calibrated_confidence": safe_round(cal_prob * 100, 1),
        "signal": "BUY" if cal_prob > 0.53 else "AVOID",
        "rsi": result.get("rsi", 0),
        "momentum": result.get("momentum", 0),
        "sma_50": result.get("sma_50", 0),
        "sma_200": result.get("sma_200", 0),
        "volatility_20": result.get("volatility_20", 0),
        "price": result.get("price", 0),
        "prev_close": result.get("prev_close", 0),
    }


def predict_batch(tickers: list[str]) -> list[dict]:
    results = []
    for ticker in tickers:
        r = predict(ticker.upper().strip())
        if "error" not in r:
            results.append(r)
        else:
            print(f"  [{ticker}] skipped — {r.get('error', 'unknown')}")
    return sorted(
        results,
        key=lambda x: x.get("calibrated_confidence", 0),
        reverse=True,
    )


def top_movers(n: int = 20) -> list[dict]:
    latest_dir = sage._latest_non_empty_year_dir()
    if latest_dir is None:
        print("[INFERENCE] No historical data found.")
        return []
    tickers = [f.stem.rsplit("-", 1)[0] for f in sorted(latest_dir.glob("*-*.csv"))]
    print(f"[INFERENCE] Scoring {len(tickers)} tickers...")
    return predict_batch(tickers)[:n]


# ── Formatting ────────────────────────────────────────────────────────────────


def _bar(value: float, max_val: float = 100.0, width: int = 20) -> str:
    filled = max(0, min(int(round((value / max_val) * width)), width))
    return "█" * filled + "░" * (width - filled)


def print_result(r: dict) -> None:
    ticker = r["ticker"]
    signal = r.get("signal", "N/A")
    raw_c = r.get("confidence", 0)
    cal_c = r.get("calibrated_confidence", raw_c)
    price = r.get("price", 0)
    rsi = r.get("rsi", 0)
    sma50 = r.get("sma_50", 0)
    sma200 = r.get("sma_200", 0)
    mom = r.get("momentum", 0)
    vol = r.get("volatility_20", 0)
    dr = r.get("daily_return", 0)
    last5 = r.get("last5_returns", "")

    icon = "🟢 BUY  " if signal == "BUY" else "🔴 AVOID"
    print(f"\n{'─' * 52}")
    print(f"  {ticker:<8}  {icon}  ${price:.2f}")
    print(f"{'─' * 52}")
    print(f"  Raw confidence   : {raw_c:>5.1f}%  {_bar(raw_c)}")
    print(f"  Cal. confidence  : {cal_c:>5.1f}%  {_bar(cal_c)}")
    print(f"  RSI-14           : {rsi:>6.1f}")
    print(f"  SMA 50 / 200     : ${sma50:.2f} / ${sma200:.2f}")
    print(f"  Momentum (5d)    : {mom:>+.2f}%")
    print(f"  Daily return     : {dr:>+.2f}%")
    print(f"  Ann. volatility  : {vol:.1f}%")
    if last5:
        print(f"  Last 5 returns   : {last5}")
    print(f"{'─' * 52}")


def print_batch_summary(results: list[dict]) -> None:
    if not results:
        print("No results.")
        return
    header = (
        f"  {'#':>3}  {'Ticker':<8}  {'Signal':<6}  "
        f"{'Cal.Conf':>8}  {'Price':>8}  {'RSI':>6}  {'Mom':>7}"
    )
    print(f"\n{'═' * len(header)}")
    print(header)
    print(f"{'═' * len(header)}")
    for i, r in enumerate(results, 1):
        signal_str = "BUY  " if r.get("signal") == "BUY" else "AVOID"
        cal_c = r.get("calibrated_confidence", r.get("confidence", 0))
        print(
            f"  {i:>3}.  {r['ticker']:<8}  {signal_str:<6}  "
            f"{cal_c:>7.1f}%  ${r.get('price', 0):>7.2f}  "
            f"{r.get('rsi', 0):>5.1f}  {r.get('momentum', 0):>+6.2f}%"
        )
    print(f"{'═' * len(header)}\n")


# ── CLI ───────────────────────────────────────────────────────────────────────


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="SAGE Inference — research tool for S&P 500 tickers\n"
        "⚠️  Output is for educational/research use only, not financial advice.",
        formatter_class=argparse.RawTextHelpFormatter,
    )
    parser.add_argument(
        "tickers",
        nargs="*",
        metavar="TICKER",
        help="One or more ticker symbols (e.g. AAPL MSFT NVDA)",
    )
    parser.add_argument(
        "--top",
        type=int,
        default=0,
        metavar="N",
        help="Score all local tickers and show top N by confidence (e.g. --top 20)",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print full detail for each ticker instead of a summary table",
    )
    return parser.parse_args()


def main() -> None:
    args = _parse_args()

    if not args.tickers and not args.top:
        print(
            "Usage: python inference.py AAPL MSFT   OR   python inference.py --top 20"
        )
        sys.exit(1)

    print("[INFERENCE] Loading model...")
    if not sage.load_model():
        print("[INFERENCE] ERROR: Could not load model. Run train_sage.py first.")
        sys.exit(1)

    load_calibrator()

    if args.top:
        print(f"[INFERENCE] Scoring all local tickers, showing top {args.top}...")
        results = top_movers(n=args.top)
    else:
        tickers = [t.upper() for t in args.tickers]
        print(f"[INFERENCE] Running inference on: {', '.join(tickers)}")
        results = predict_batch(tickers)

    if not results:
        print("[INFERENCE] No valid results.")
        sys.exit(0)

    if args.verbose or len(results) == 1:
        for r in results:
            print_result(r)
    else:
        print_batch_summary(results)

    buys = sum(1 for r in results if r.get("signal") == "BUY")
    avoids = len(results) - buys
    print(
        f"  Summary: {len(results)} tickers scored — {buys} BUY, {avoids} AVOID\n"
        f"  ⚠️  For educational/research use only, not financial advice.\n"
    )


if __name__ == "__main__":
    main()
