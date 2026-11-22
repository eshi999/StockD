# fetch_sp500.py — Download and cache S&P 500 historical data
# Usage: python fetch_sp500.py

import logging
import re
import sys
from datetime import datetime, timedelta
from pathlib import Path

import pandas as pd
import yfinance as yf

# ── Paths ──────────────────────────────────────────────────────────────────────
BASE_DIR = Path(__file__).parent.resolve()
HIST_DIR = BASE_DIR / "historical"
LOG_FILE = BASE_DIR / "fetch_sp500.log"
CONSTITUENTS_FILE = BASE_DIR / "sp500_constituents.csv"
HISTORICAL_COMP_FILE = BASE_DIR / "sp_500_historical_components.csv"

# ── Logging ────────────────────────────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler(sys.stdout),
    ],
)
log = logging.getLogger(__name__)

# ── Config ─────────────────────────────────────────────────────────────────────
TODAY = datetime.today().date()


def _most_recent_weekday(d):
    """Return d or the nearest previous weekday (Mon=0 ... Fri=4)."""
    while d.weekday() >= 5:
        d -= timedelta(days=1)
    return d


YESTERDAY = _most_recent_weekday(TODAY - timedelta(days=1))
START_YEAR = TODAY.year - 1
YEARS = list(range(START_YEAR, TODAY.year + 1))

CSV_COLUMNS = [
    "Date",
    "Ticker",
    "Company_Name",
    "Sector",
    "Industry",
    "Open",
    "High",
    "Low",
    "Close",
    "Volume",
    "SMA_50",
    "SMA_200",
    "RSI_14",
    "Daily_Return",
    "Volatility_20",
]

_INFO_CACHE: dict[str, dict] = {}

RENAMED = {
    "ABC": "COR",
    "ADS": "BFH",
    "ANTM": "ELV",
    "FB": "META",
    "RTN": "RTX",
    "UTX": "RTX",
    "CBS": "PARA",
    "VIAC": "PARA",
    "ALXN": "AZN",
    "ATVI": "MSFT",
}


# ── Technical Analysis ────────────────────────────────────────────────────────


def calculate_technical_features(df: pd.DataFrame) -> pd.DataFrame:
    """Calculates point-in-time indicators SAGE needs for training."""
    df["SMA_50"] = df["Close"].rolling(window=50).mean()
    df["SMA_200"] = df["Close"].rolling(window=200).mean()

    delta = df["Close"].diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
    rs = gain / (loss + 1e-9)

    df["RSI_14"] = 100 - (100 / (1 + rs))
    df["Daily_Return"] = df["Close"].pct_change()
    df["Volatility_20"] = df["Daily_Return"].rolling(window=20).std()
    return df


# ── Ticker Normalization ──────────────────────────────────────────────────────


def normalize_ticker(raw: str) -> str:
    """Strips leading symbols and standardizes for yfinance."""
    t = str(raw).strip().upper()
    t = t.replace("$", "")
    t = re.sub(r"\s*\(.*?\)", "", t).strip()
    return t.replace(".", "-")


def get_tickers_for_year(year: int) -> set:
    """Extracts tickers from local CSV membership files."""
    tickers: set[str] = set()

    if HISTORICAL_COMP_FILE.exists():
        hist = pd.read_csv(  # type: ignore[call-overload]
            HISTORICAL_COMP_FILE,
            parse_dates=["date"],
        )
        mask = hist["date"].dt.year == year
        year_rows = hist.loc[mask]
        if not year_rows.empty:
            raw_list = str(year_rows.sort_values("date").iloc[-1]["tickers"]).split(",")
            for t in raw_list:
                if clean := normalize_ticker(t):
                    tickers.add(clean)

    if year == TODAY.year and CONSTITUENTS_FILE.exists():
        curr = pd.read_csv(CONSTITUENTS_FILE)
        if "symbol" in curr.columns:
            for t in curr["symbol"].dropna():
                tickers.add(normalize_ticker(str(t)))

    return tickers


# ── Fetching & Saving ─────────────────────────────────────────────────────────


def fetch_and_save(ticker: str, year: int, out_dir: Path) -> bool:
    out_path = out_dir / f"{ticker}-{year}.csv"

    if out_path.exists():
        if year < TODAY.year:
            log.info(f"[{year}] {ticker:<6} - OK (Cached)")
            return True
        try:
            existing = pd.read_csv(  # type: ignore[call-overload]
                out_path,
                usecols=lambda c: c == "Date",
                parse_dates=["Date"],
            )
            last_date = existing["Date"].max().date()
            if last_date >= YESTERDAY:
                log.info(f"[{year}] {ticker:<6} - OK (Up-to-date, last={last_date})")
                return True
            else:
                log.info(
                    f"[{year}] {ticker:<6} - Stale "
                    f"(last={last_date}, fetching to {YESTERDAY})"
                )
                out_path.unlink()
        except Exception:
            log.info(f"[{year}] {ticker:<6} - Re-fetching (could not read cached file)")
            out_path.unlink(missing_ok=True)

    fetch_as = RENAMED.get(ticker, ticker)
    start_dt = datetime(year, 1, 1)
    fetch_start = (start_dt - timedelta(days=365)).strftime("%Y-%m-%d")
    end_date = (
        (TODAY + timedelta(days=1)).strftime("%Y-%m-%d")
        if year == TODAY.year
        else f"{year}-12-31"
    )

    try:
        t_obj = yf.Ticker(fetch_as)
        history = t_obj.history(start=fetch_start, end=end_date, auto_adjust=True)
        if not isinstance(history, pd.DataFrame) or history.empty:
            return False

        df = calculate_technical_features(history.reset_index())

        info = t_obj.info if ticker not in _INFO_CACHE else _INFO_CACHE[ticker]
        df["Ticker"] = ticker
        df["Company_Name"] = info.get("shortName", ticker)
        df["Sector"] = info.get("sector", "Unknown")
        df["Industry"] = info.get("industry", "Unknown")
        _INFO_CACHE[ticker] = info

        df["Date"] = pd.to_datetime(df["Date"]).dt.tz_localize(None)
        df = df[df["Date"].dt.year == year]

        if not df.empty:
            pd.DataFrame(df.loc[:, CSV_COLUMNS]).to_csv(out_path, index=False)
            log.info(f"[{year}] {ticker:<6} - OK (Saved)")
            return True

    except Exception:
        return False

    return False


# ── Main ───────────────────────────────────────────────────────────────────────


def main():
    log.info("=" * 60)
    log.info("Starting SAGE S&P 500 Fetcher (A → Z)")
    log.info("=" * 60)

    HIST_DIR.mkdir(exist_ok=True)

    for year in YEARS:
        year_dir = HIST_DIR / str(year)
        year_dir.mkdir(exist_ok=True)

        tickers = sorted(get_tickers_for_year(year))
        log.info(f"[{year}] Processing {len(tickers)} tickers alphabetically...")

        for ticker in tickers:
            fetch_and_save(ticker, year, year_dir)


if __name__ == "__main__":
    main()
