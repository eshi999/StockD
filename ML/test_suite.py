import os
import logging
import pandas as pd
import numpy as np
import yfinance as yf
import tensorflow as tf
from sklearn.preprocessing import StandardScaler
from pathlib import Path

# --- 1. SILENCE THE NOISE ---
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'
logging.getLogger('tensorflow').setLevel(logging.ERROR)

# --- 2. CONFIGURATION ---
BASE_DIR = Path(__file__).parent.resolve()
HIST_DIR = Path("/home/gautam/StockD/ML/historical/") 
MODEL_FILE = BASE_DIR / "sage_model.h5"
WINDOW_SIZE = 30
FEATURE_COLS = ["Open", "High", "Low", "Close", "Volume", "SMA_50", "SMA_200", "RSI_14", "Daily_Return", "Volatility_20"]

# --- 3. HARDWARE OPTIMIZATION ---
def setup_hardware():
    """Optimizes RTX 4050 (Linux) and Apple Silicon (Mac) automatically."""
    gpus = tf.config.list_physical_devices('GPU')
    if gpus:
        try:
            for gpu in gpus:
                tf.config.experimental.set_memory_growth(gpu, True)
            print(f"✔️ Hardware: GPU Acceleration Active.")
        except RuntimeError as e: print(f"⚠️ GPU Note: {e}")
    else:
        print("ℹ️ Hardware: CPU (oneDNN accelerated).")

setup_hardware()

def load_sage():
    if not MODEL_FILE.exists():
        print(f"❌ Error: {MODEL_FILE} not found!")
        return None
    return tf.keras.models.load_model(MODEL_FILE)

# --- 4. FULL DATASET BACKTEST (2016-2026) ---
def run_full_backtest(model):
    print(f"\n--- ⏳ FULL DATASET SIMULATION (2016-2026) ---")
    all_files = list(HIST_DIR.rglob("*.csv"))
    if not all_files:
        print("❌ Error: No CSV files found.")
        return

    total_correct = 0
    total_predictions = 0

    print(f"Processing {len(all_files)} ticker-year files...")

    for f in all_files:
        try:
            df = pd.read_csv(f)
            df['Date'] = pd.to_datetime(df['Date'])
            df = df.sort_values('Date')
            
            # Ensure enough data for a 30-day window + 5-day future target
            if len(df) < (WINDOW_SIZE + 5): continue

            # Generate Target (1 = Gain, 0 = Loss/Flat after 5 days)
            df['Target'] = (df['Close'].shift(-5) > df['Close']).astype(int)
            df = df.dropna(subset=['Target'])

            # Normalize features so Sage understands the scale
            scaler = StandardScaler()
            scaled_data = scaler.fit_transform(df[FEATURE_COLS])
            
            X_batch = []
            y_actuals = []
            
            # Collect windows for the ENTIRE file length
            for i in range(WINDOW_SIZE, len(df)):
                X_batch.append(scaled_data[i-WINDOW_SIZE:i])
                y_actuals.append(df['Target'].iloc[i])

            if not X_batch: continue

            # Send the entire batch to the GPU at once
            X_batch = np.array(X_batch)
            probs = model.predict(X_batch, batch_size=1024, verbose=0)
            preds = (probs > 0.5).astype(int).flatten()
            
            total_correct += np.sum(preds == np.array(y_actuals))
            total_predictions += len(y_actuals)
                
        except Exception: continue

    if total_predictions > 0:
        final_acc = (total_correct / total_predictions)
        print(f"\n✅ SIMULATION COMPLETE")
        print(f"Total Sequences Analyzed: {total_predictions:,}")
        print(f"Full Period Accuracy (2016-2026): {final_acc:.2%}")
        
        # Concept: Why 2016-2026 matters
        if final_acc > 0.51:
            print("Status: Sage is outperforming random chance across the full decade.")
    else:
        print("❌ No valid data sequences found in the provided directory.")

# --- 5. LIVE PREDICTION ENGINE ---
def run_live(ticker, model):
    print(f"\n--- 🛰️ LIVE PREDICTION: {ticker} ---")
    df = yf.download(ticker, period="1y", auto_adjust=True)
    if df.empty or len(df) < 200:
        print("❌ Error: Not enough data history for technical analysis.")
        return

    # Calculate indicators on the fly
    df['SMA_50'] = df['Close'].rolling(window=50).mean()
    df['SMA_200'] = df['Close'].rolling(window=200).mean()
    delta = df['Close'].diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
    df['RSI_14'] = 100 - (100 / (1 + (gain / (loss + 1e-9))))
    df['Daily_Return'] = df['Close'].pct_change()
    df['Volatility_20'] = df['Daily_Return'].rolling(window=20).std()
    
    df = df.dropna()
    scaler = StandardScaler()
    scaled_data = scaler.fit_transform(df[FEATURE_COLS])
    input_seq = np.expand_dims(scaled_data[-WINDOW_SIZE:], axis=0)

    prob = model.predict(input_seq, verbose=0)[0][0]
    print(f"Signal Confidence: {prob:.2%}")
    print(f"ACTION: {'🟢 BUY' if prob > 0.53 else '🔴 AVOID'}")

if __name__ == "__main__":
    sage_model = load_sage()
    if sage_model:
        while True:
            print("\n--- SAGE OPERATIONAL MENU ---")
            print("1: Live Market Analysis")
            print("2: Full Simulation (2016-2026)")
            print("3: Exit")
            
            choice = input("\nSelect: ").strip()
            if choice == '1':
                run_live(input("Enter Ticker: ").upper(), sage_model)
            elif choice == '2':
                run_full_backtest(sage_model)
            elif choice == '3':
                break
            elif len(choice) > 1: # Ticker short-cut
                run_live(choice.upper(), sage_model)
