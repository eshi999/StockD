import sys
import pandas as pd
import numpy as np
from datetime import datetime
from polygon import load_cache, market_health, SP500

CACHE_FILE     = "sp500_data.csv"
OUTPUT_FILE    = "scores.csv"
TOP_N          = 20
MIN_DAYS       = 10


def compute_rsi(closes: pd.Series, period: int = 14) -> float:
    delta  = closes.diff().dropna()
    gain   = delta.clip(lower=0)
    loss   = -delta.clip(upper=0)

    avg_gain = gain.rolling(window=period, min_periods=period).mean().iloc[-1]
    avg_loss = loss.rolling(window=period, min_periods=period).mean().iloc[-1]

    if avg_loss == 0:
        return 100.0

    rs  = avg_gain / avg_loss
    rsi = 100 - (100 / (1 + rs))
    return round(rsi, 2)


def compute_price_momentum(closes: pd.Series) -> float:
    if len(closes) < 2:
        return 0.0
    start = closes.iloc[0]
    end   = closes.iloc[-1]
    if start == 0:
        return 0.0
    pct = ((end - start) / start) * 100
    return round(pct, 2)


def compute_volume_trend(volumes: pd.Series) -> float:
    if len(volumes) < 4:
        return 0.0
    half     = len(volumes) // 2
    recent   = volumes.iloc[half:].mean()
    earlier  = volumes.iloc[:half].mean()
    if earlier == 0:
        return 0.0
    trend = ((recent - earlier) / earlier) * 100
    return round(trend, 2)


def normalize(value: float, min_val: float, max_val: float) -> float:
    if max_val == min_val:
        return 50.0
    return max(0.0, min(100.0, (value - min_val) / (max_val - min_val) * 100))


def score_ticker(ticker_data: pd.DataFrame) -> dict:
    ticker_data = ticker_data.sort_values("date").reset_index(drop=True)
    closes      = ticker_data["close"]
    volumes     = ticker_data["volume"]
    ticker      = ticker_data["ticker"].iloc[0]

    price_momentum = compute_price_momentum(closes)
    volume_trend   = compute_volume_trend(volumes)
    rsi            = compute_rsi(closes) if len(closes) >= 14 else 50.0

    rsi_score = normalize(rsi, 0, 100)
    if rsi > 70:
        rsi_score *= 0.7
    elif rsi < 30:
        rsi_score *= 1.3

    raw_score = (
        price_momentum * 0.50 +
        volume_trend   * 0.25 +
        rsi_score      * 0.25
    )

    return {
        "ticker":          ticker,
        "company":         SP500.get(ticker, ticker),
        "price_momentum":  price_momentum,
        "volume_trend":    volume_trend,
        "rsi":             rsi,
        "raw_score":       raw_score,
        "latest_close":    round(closes.iloc[-1], 2),
        "days":            len(ticker_data),
    }


def apply_market_adjustment(scores_df: pd.DataFrame, health: dict) -> pd.DataFrame:
    h = health["health_score"]

    if h >= 70:
        multiplier = 1.10
    elif h >= 50:
        multiplier = 1.00
    elif h >= 30:
        multiplier = 0.90
    else:
        multiplier = 0.80

    scores_df["momentum_score"] = (scores_df["raw_score"] * multiplier)

    min_s = scores_df["momentum_score"].min()
    max_s = scores_df["momentum_score"].max()
    scores_df["momentum_score"] = scores_df["momentum_score"].apply(
        lambda x: round(normalize(x, min_s, max_s))
    )

    return scores_df


def explain_score(row: pd.Series, health: dict) -> str:
    lines = []

    if row["price_momentum"] > 10:
        lines.append(f"Price is up {row['price_momentum']:.1f}% over the period — strong upward trend.")
    elif row["price_momentum"] > 0:
        lines.append(f"Price is up {row['price_momentum']:.1f}% — modest positive momentum.")
    elif row["price_momentum"] > -5:
        lines.append(f"Price is slightly down {abs(row['price_momentum']):.1f}% — weak momentum.")
    else:
        lines.append(f"Price is down {abs(row['price_momentum']):.1f}% — negative trend.")

    if row["volume_trend"] > 20:
        lines.append(f"Volume has increased {row['volume_trend']:.1f}% recently — more people are trading this stock, which often confirms a move.")
    elif row["volume_trend"] > 0:
        lines.append(f"Volume is slightly higher than usual — mild interest from traders.")
    else:
        lines.append(f"Volume is declining — fewer traders are active in this stock right now.")

    if row["rsi"] > 70:
        lines.append(f"RSI is {row['rsi']:.0f} — overbought territory. The stock may have run up too fast and could pull back soon.")
    elif row["rsi"] > 50:
        lines.append(f"RSI is {row['rsi']:.0f} — healthy momentum without being overextended.")
    elif row["rsi"] > 30:
        lines.append(f"RSI is {row['rsi']:.0f} — below neutral, momentum is weakening.")
    else:
        lines.append(f"RSI is {row['rsi']:.0f} — oversold. Could bounce, but also signals sustained selling pressure.")

    h = health["health_score"]
    if h >= 70:
        lines.append(f"The broader market is strong today (health score {h}/100), which boosts this stock's score.")
    elif h >= 50:
        lines.append(f"The broader market is neutral today (health score {h}/100) — no boost or penalty applied.")
    elif h >= 30:
        lines.append(f"The broader market is under pressure (health score {h}/100), which reduces this score slightly.")
    else:
        lines.append(f"The market is in poor health today (health score {h}/100) — scores are significantly reduced.")

    return " ".join(lines)


def print_education(health: dict):
    h      = health["health_score"]
    change = health["sp500_change"]
    adr    = health["ad_ratio"]
    pma    = health["pct_above_ma"]

    print("\n  What does this mean for you as an investor?")
    print("  " + "─" * 58)

    if change > 0:
        print(f"  The average S&P 500 stock moved UP {change:+.2f}% today.")
        print(f"  This means most large US companies gained value.")
    else:
        print(f"  The average S&P 500 stock moved DOWN {change:.2f}% today.")
        print(f"  This means most large US companies lost value.")

    print()

    if adr >= 2:
        print(f"  {health['advancing']} stocks advanced vs {health['declining']} declining (ratio: {adr:.2f}).")
        print(f"  More than 2x as many stocks went up as down — this is a broad rally,")
        print(f"  not just a few big names pulling the index higher.")
    elif adr >= 1:
        print(f"  {health['advancing']} stocks advanced vs {health['declining']} declining (ratio: {adr:.2f}).")
        print(f"  More stocks went up than down, but the margin is narrow.")
        print(f"  The market is cautiously positive.")
    else:
        print(f"  {health['advancing']} stocks advanced vs {health['declining']} declining (ratio: {adr:.2f}).")
        print(f"  More stocks fell than rose — this is a broad selloff, not just a")
        print(f"  few weak names dragging the index down.")

    print()

    if pma >= 70:
        print(f"  {pma:.1f}% of S&P 500 stocks are trading above their 50-day average.")
        print(f"  A 50-day moving average smooths out daily noise to show the true trend.")
        print(f"  When most stocks are above it, the market has sustained upward momentum.")
    elif pma >= 50:
        print(f"  {pma:.1f}% of stocks are above their 50-day average — mixed signals.")
        print(f"  Roughly half the market is trending up, half is trending down.")
        print(f"  Be selective about which stocks you pay attention to right now.")
    else:
        print(f"  Only {pma:.1f}% of stocks are above their 50-day average.")
        print(f"  Most stocks are in a downtrend. High momentum scores today")
        print(f"  are rarer and more meaningful — those stocks are fighting the tide.")

    print()

    if h >= 70:
        print(f"  Overall: The market is healthy. Good conditions to study momentum stocks.")
    elif h >= 50:
        print(f"  Overall: The market is mixed. Focus on stocks with strong individual signals.")
    elif h >= 30:
        print(f"  Overall: The market is under stress. Even strong stocks may struggle.")
    else:
        print(f"  Overall: Bear conditions. Momentum scores are dampened accordingly.")

    print("  " + "─" * 58)


def run_scorer():
    cache = load_cache()

    if cache.empty:
        print("ERROR: No data in cache. Run 'python3 polygon.py' first.")
        return

    health = market_health()

    if health is None:
        print("ERROR: Could not compute market health.")
        return

    print_education(health)

    total   = cache["ticker"].nunique()
    counted = 0
    skipped = 0
    results = []

    print(f"\n  Scoring {total} stocks...\n")

    for ticker, group in cache.groupby("ticker"):
        counted += 1

        if len(group) < MIN_DAYS:
            skipped += 1
            print(f"  [{counted:>3}/{total}] {ticker:<8} — skipped (only {len(group)} days of data, need {MIN_DAYS})")
            continue

        result = score_ticker(group)
        results.append(result)
        company = SP500.get(ticker, ticker)[:28]
        print(f"  [{counted:>3}/{total}] {ticker:<8} {company:<30}  score: {round(result['raw_score']):>4}  momentum: {result['price_momentum']:>+6.1f}%  RSI: {result['rsi']:>5.1f}")

    scores_df = pd.DataFrame(results)
    scores_df = apply_market_adjustment(scores_df, health)
    scores_df = scores_df.sort_values("momentum_score", ascending=False).reset_index(drop=True)

    scores_df.to_csv(OUTPUT_FILE, index=False)

    top = scores_df.head(TOP_N)

    print(f"  Top {TOP_N} Momentum Stocks — {health['date']}")
    print(f"  Market Health: {health['health_score']}/100")
    print(f"  {'─' * 100}")
    print(f"  {'Rank':<5} {'Ticker':<8} {'Company':<35} {'Score':>6} {'Price':>8} {'Momentum':>10} {'Vol Trend':>10} {'RSI':>6}")
    print(f"  {'─' * 100}")

    for i, row in top.iterrows():
        print(f"  {i+1:<5} {row['ticker']:<8} {row['company'][:33]:<35} "
              f"{row['momentum_score']:>6} "
              f"${row['latest_close']:>7.2f} "
              f"{row['price_momentum']:>+9.1f}% "
              f"{row['volume_trend']:>+9.1f}% "
              f"{row['rsi']:>6.1f}")

    print(f"  {'─' * 100}")
    print(f"\n  Scored {len(scores_df)} stocks, skipped {skipped} (insufficient data).")
    print(f"  Full scores saved to: {OUTPUT_FILE}")

    print(f"\n  Why is the #1 stock ranked first?")
    print(f"  {explain_score(top.iloc[0], health)}\n")

    return scores_df


if __name__ == "__main__":
    if len(sys.argv) > 1:
        ticker = sys.argv[1].upper()
        cache  = load_cache()

        if cache.empty:
            print("ERROR: No data in cache. Run 'python3 polygon.py' first.")
            sys.exit(1)

        ticker_data = cache[cache["ticker"] == ticker]

        if ticker_data.empty:
            print(f"ERROR: No data found for {ticker} in cache.")
            sys.exit(1)

        health = market_health()
        result = score_ticker(ticker_data)
        row    = pd.Series(result)

        print(f"\n  Score for {ticker} ({SP500.get(ticker, 'Unknown')})")
        print(f"  {'─' * 50}")
        print(f"  Momentum Score : {round(result['raw_score'])}/100")
        print(f"  Price Momentum : {result['price_momentum']:+.2f}%")
        print(f"  Volume Trend   : {result['volume_trend']:+.2f}%")
        print(f"  RSI            : {result['rsi']:.1f}")
        print(f"  Latest Close   : ${result['latest_close']:.2f}")
        print(f"  {'─' * 50}")
        print(f"\n  {explain_score(row, health)}\n")
    else:
        run_scorer()
