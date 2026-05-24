from pathlib import Path

import pandas as pd
from ml_config import FEATURE_COLS, HORIZON_DAYS

BASE_DIR = Path(__file__).parent.resolve()
HIST_DIR = BASE_DIR / "historical"
OUTPUT_FILE = BASE_DIR / "sage_training_data.csv"

REQUIRED_BASE_COLUMNS = ["Date", "Ticker", "Close"]
OPTIONAL_METADATA_COLUMNS = ["Company_Name", "Sector", "Industry"]


def load_one_csv(file_path: Path) -> pd.DataFrame | None:
    try:
        df = pd.read_csv(file_path)
    except Exception as exc:
        print(f"[WARN] Failed to read {file_path}: {exc}")
        return None

    if df.empty:
        return None

    missing = [col for col in REQUIRED_BASE_COLUMNS if col not in df.columns]
    if missing:
        print(f"[WARN] Skipping {file_path}: missing required columns {missing}")
        return None

    missing_features = [col for col in FEATURE_COLS if col not in df.columns]
    if missing_features:
        print(
            f"[WARN] Skipping {file_path}: missing feature columns {missing_features}"
        )
        return None

    keep_cols = list(
        dict.fromkeys(REQUIRED_BASE_COLUMNS + OPTIONAL_METADATA_COLUMNS + FEATURE_COLS)
    )
    available_cols = [col for col in keep_cols if col in df.columns]

    out = pd.DataFrame(df.loc[:, available_cols]).copy()
    out["Date"] = pd.to_datetime(out["Date"], errors="coerce")
    out["Ticker"] = pd.Series(out["Ticker"], dtype="string").str.strip().str.upper()

    out = out.dropna(axis=0, subset=["Date", "Ticker", "Close"])
    if out.empty:
        return None

    out = out.sort_values("Date").reset_index(drop=True)

    out["FutureReturn"] = out["Close"].shift(-HORIZON_DAYS) / out["Close"] - 1.0
    out["Target"] = (out["FutureReturn"] > 0).astype(int)

    out = out.dropna(axis=0, subset=FEATURE_COLS + ["FutureReturn"]).reset_index(
        drop=True
    )
    if out.empty:
        return None

    return out


def consolidate() -> pd.DataFrame:
    if not HIST_DIR.exists():
        raise FileNotFoundError(f"Historical directory not found: {HIST_DIR}")

    csv_files = sorted(HIST_DIR.rglob("*.csv"))
    print(f"Found {len(csv_files)} historical CSV files in {HIST_DIR}")

    all_dfs: list[pd.DataFrame] = []
    skipped = 0

    for idx, file_path in enumerate(csv_files, start=1):
        df = load_one_csv(file_path)
        if df is None:
            skipped += 1
            continue
        all_dfs.append(df)

        if idx % 500 == 0 or idx == len(csv_files):
            print(f"Processed {idx}/{len(csv_files)} files...")

    if not all_dfs:
        raise RuntimeError("No usable CSV files were found under historical/")

    master_df = pd.concat(all_dfs, ignore_index=True)
    master_df["Date"] = pd.to_datetime(master_df["Date"], errors="coerce")
    master_df = master_df.dropna(
        subset=["Date", "Ticker", "Close", "FutureReturn"]
    ).copy()
    master_df.sort_values(["Ticker", "Date"], inplace=True)
    master_df.reset_index(drop=True, inplace=True)

    return master_df


def main() -> None:
    print("Starting consolidation...")
    master_df = consolidate()
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    master_df.to_csv(OUTPUT_FILE, index=False)

    print("Consolidation complete.")
    print(f"Saved: {OUTPUT_FILE}")
    print(f"Rows: {len(master_df)}")
    print(f"Tickers: {master_df['Ticker'].nunique()}")
    print(f"Date range: {master_df['Date'].min()} -> {master_df['Date'].max()}")


if __name__ == "__main__":
    main()
