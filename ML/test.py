import pandas as pd
import numpy as np
from pathlib import Path
from sklearn.preprocessing import StandardScaler

# --- Configuration ---
BASE_DIR = Path(__file__).parent.resolve()
HIST_DIR = BASE_DIR / "historical"
OUTPUT_FILE = BASE_DIR / "sage_training_data.csv"
PREDICTION_DAYS = 5 

def aggregate_and_label():
    all_dfs = []
    # Find all CSVs in the 2016-2026 folders
    csv_files = list(HIST_DIR.rglob("*.csv"))
    print(f"Aggregating {len(csv_files)} files from 2016-2026...")

    for i, file_path in enumerate(csv_files):
        try:
            df = pd.read_csv(file_path)
            if df.empty or len(df) < 10: continue
            
            # Labeling: 1 if price is higher in 5 trading days
            df['Target'] = (df['Close'].shift(-PREDICTION_DAYS) > df['Close']).astype(int)
            
            # Drop the rows that don't have a 'future' yet
            df = df.dropna()
            all_dfs.append(df)
            
            if i % 500 == 0: print(f"Progress: {i}/{len(csv_files)} files...")
        except Exception:
            continue

    master_df = pd.concat(all_dfs, ignore_index=True)
    return master_df

def scale_features(df):
    features = ["Open", "High", "Low", "Close", "Volume", "SMA_50", "SMA_200", "RSI_14", "Daily_Return", "Volatility_20"]
    scaler = StandardScaler()
    df[features] = scaler.fit_transform(df[features])
    return df

if __name__ == "__main__":
    master_data = aggregate_and_label()
    print(f"Processing complete. Dataset contains {len(master_data)} rows.")
    master_data = scale_features(master_data)
    master_data.to_csv(OUTPUT_FILE, index=False)
    print(f"Master file saved: {OUTPUT_FILE}")
