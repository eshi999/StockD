# StockD
Gamified stock market literacy — powered by a real AI coach.

StockD is a desktop-first Flutter app that teaches stock market fundamentals through Duolingo-style progression, anchored to **historical S&P 500 data**. It is **not a trading tool, not a prediction engine, and not financial advice.**

> "SAGE explains. The user decides."

---

## Overview
StockD combines gamified lesson progression with an AI coaching layer (SAGE) that explains concepts using **historical S&P 500 data**. Users progress through worlds and levels, answering multiple-choice questions. When they get something wrong, SAGE explains why using real charts and market data — **educational only**.

The Flutter app lives in `lib/` and is organised into models, providers, services, screens, and widgets. The Python ML backend (FastAPI + TensorFlow) lives in `ML/`, with data scripts and model artifacts kept separate from source.

---

## Features
- Duolingo-style progression — Worlds, Levels, 10 questions each, with XP, streaks, and hearts
- Paper trading simulation — Practice buying and selling with $10,000 of virtual cash
- SAGE AI Coach — Explains wrong answers with real S&P 500 context and interactive charts
- SAGE Chat — Ask any stock market question at any time via an educational chatbot
- Real market data — Lessons reference actual tickers, RSI, SMA, volatility, and price history
- Desktop-first — Built with Flutter for Linux, macOS, and Windows
- No financial advice — Every AI response includes an explicit educational disclaimer

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter 3.x (Dart) |
| State Management | Riverpod 3.x |
| Navigation | GoRouter 17.x |
| Charts | fl_chart |
| Animations | flutter_animate |
| ML Backend | FastAPI + TensorFlow 2.x |
| Market Data | yfinance + local S&P 500 CSVs |

---

## Getting Started

### 1. Flutter UI

**Prerequisites:** Flutter 3.x, Dart SDK

```bash
git clone https://github.com/eshi999/StockD.git
cd StockD
flutter pub get
flutter run -d <your-desktop-target>
```

The UI expects the SAGE backend to be running at `http://localhost:8000`. If the backend is not running, the app launches in offline mode with simulated chart data and fallback explanations.

---

### 2. SAGE ML Backend

**Prerequisites:** Python 3.12, Conda (recommended) or pip, internet connection for the initial data fetch.

#### Create and activate the environment

Using Conda (recommended):

```bash
conda create -n ml python=3.12 -y
conda activate ml
```

Using a standard virtual environment:

```bash
python3.12 -m venv .venv
source .venv/bin/activate        # Linux / macOS
.venv\Scripts\activate           # Windows
```

#### Install dependencies

`ML/requirements.txt` is compatible with both pip and Conda:

```bash
# pip
pip install -r ML/requirements.txt

# conda
conda install -c conda-forge --file ML/requirements.txt
```

#### Start the API

With the environment active, from the repo root:

```bash
cd ML
python3.12 -m uvicorn main:app --port 8000 --reload
```

Or without `--reload` for a stable non-development session:

```bash
cd ML
python3.12 -m uvicorn main:app --port 8000
```

#### Verify the backend is running

```bash
# Linux / macOS
curl http://localhost:8000/health

# Windows (PowerShell)
Invoke-WebRequest http://localhost:8000/health
```

Expected response:

```json
{ "status": "ok", "model_loaded": true }
```

#### Test SAGE chat

```bash
curl -X POST http://localhost:8000/sage/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What is RSI?", "history": []}'
```

---

## Retraining SAGE

Pre-trained model artifacts are included in `ML/artifacts/`. If you want to retrain the model on fresh market data, follow the full pipeline below. Steps must be run in order.

**All commands assume your environment is active and you are inside the `ML/` directory.**

```bash
cd ML
conda activate ml    # or source your venv
```

### Step 1 — Fetch historical S&P 500 data

Downloads up to 10 years of daily OHLCV data for S&P 500 constituents from Yahoo Finance. Per-ticker CSVs are written to `ML/historical/<year>/`.

```bash
python3.12 fetch_sp500.py
```

This step takes a significant amount of time (roughly 30 to 90 minutes depending on your connection and the number of tickers). It is safe to interrupt and re-run — already-downloaded files are skipped.

### Step 2 — Consolidate into a single training file

Merges all per-ticker CSVs into `ML/sage_training_data.csv` and computes `FutureReturn` and `Target` columns.

```bash
python3.12 consolidate.py
```

### Step 3 — Prepare features and artifacts

Validates the consolidated dataset, drops incomplete rows, fits the scaler, and writes `ML/artifacts/metadata.json` and `ML/artifacts/feature_scaler.pkl`.

```bash
python3.12 prepare.py
```

### Step 4 — Train the model

Trains the SAGE neural network and saves the best checkpoint to `ML/artifacts/sage_model.keras`.

```bash
python3.12 train_sage.py
```

### Step 5 — Calibrate confidence thresholds (optional)

Calibrates the HIGH/LOW confidence bands used by the model for buy/avoid signals.

```bash
python3.12 calibrate.py
```

### Step 6 — Build the lesson dataset (optional)

Runs inference on the full training set and writes `ML/artifacts/lesson_dataset.jsonl`, used for curriculum-aligned explanations.

```bash
python3.12 build_lesson_dataset.py
```

After retraining, restart the API server to load the new artifacts.

---

## API Reference

The backend exposes the following endpoints:

| Method | Path | Description |
|--------|------|-------------|
| GET | `/health` | Health check; confirms model is loaded |
| GET | `/history/{ticker}?timeframe=1Y` | Returns OHLC close history for a ticker |
| GET | `/market/snapshot` | Returns a snapshot of key market tickers |
| POST | `/sage/explain` | Generates a SAGE explanation for a wrong answer |
| POST | `/sage/chat` | Free-form educational chat with SAGE |

---

## Curriculum

| World | Topic | Difficulty |
|-------|-------|-----------|
| 1 — Market Basics | Stocks, exchanges, indices, orders | Beginner |
| 2 — Reading the Tape | Charts, candlesticks, price action | Beginner |
| 3 — Fundamentals | Earnings, valuation, balance sheets, cash flow | Intermediate |

Each world contains 5 levels of 10 questions each. Completing any level in a world unlocks the next world.

---

## Installation Notes

### macOS

**To install:**
1. Download `StockD.app` from the releases page.
2. Move `StockD.app` into your Applications folder.
3. Launch StockD from Applications or Spotlight.

**Gatekeeper — first launch:**

Because StockD is not code-signed with an Apple Developer certificate, macOS will block it on first open.

To allow it:
1. Open **System Settings → Privacy & Security**.
2. Scroll down to the Security section — you will see a message that StockD was blocked.
3. Click **Open Anyway**.
4. Enter your password when prompted.
5. Click **Open** on the confirmation dialog.

Alternatively, strip the quarantine attribute before moving the app:

```bash
xattr -cr ~/Downloads/StockD.app
```

### Windows

- Windows SmartScreen may show "Windows protected your PC"
- Click **More info → Run anyway**
- Click **Yes** at the UAC prompt

### Linux

```bash
# Debian / Ubuntu
sudo dpkg -i stockd-linux-x64.deb
sudo apt-get install -f

# Fedora / RHEL
sudo rpm -i stockd-linux-x64.rpm
```

---

## SAGE Philosophy
- SAGE is a **coach, not an autopilot**.
- Explains concepts using plain language.
- Anchors lessons to real S&P 500 tickers and historical price data.
- Surfaces indicators (RSI, SMA, volatility) as educational context only.
- Never gives buy/sell advice or price predictions.

---

## Legal & Usage Notes
- StockD is for **educational and research purposes only**.
- No financial advice is given. Always consult a licensed professional before making investment decisions.
- Historical stock data is fetched locally from Yahoo Finance via yfinance. No raw data is redistributed.
- This repository is not intended for commercial use, redistribution, or resale.
