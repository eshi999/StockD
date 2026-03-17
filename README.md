# StockD
Gamified stock market literacy — powered by a real AI coach.

StockD is a desktop-first Flutter app that teaches stock market fundamentals through Duolingo-style progression, anchored to **historical S&P 500 data**. It is **not a trading tool, not a prediction engine, and not financial advice.**

> "SAGE explains. The user decides."

## Overview
StockD combines gamified lesson progression with an AI coaching layer (SAGE) that explains concepts using **historical S&P 500 data**. Users progress through worlds and levels, answering multiple-choice questions. When they get something wrong, SAGE explains why using real charts and market data — **educational only**.

The Flutter app lives in `lib/` and is organized into models, providers, services, screens, and widgets. The Python ML backend (FastAPI + TensorFlow) lives in `ML/`, with data scripts and model artifacts kept separate from source.

## Features
- Duolingo-style progression — Worlds → Levels → 20 questions each, with XP, streaks, and hearts  
- SAGE AI Coach — Explains wrong answers with real S&P 500 context and interactive charts  
- SAGE Chat — Ask any stock market question at any time via an educational chatbot  
- Real market data — Lessons reference actual tickers, RSI, SMA, volatility, and price history  
- Desktop-first — Built with Flutter for Linux, macOS, and Windows  
- No financial advice — Every AI response includes an explicit educational disclaimer

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter 3.x (Dart) |
| State Management | Riverpod 3.x |
| Navigation | GoRouter 17.x |
| Charts | fl_chart |
| Animations | flutter_animate |
| ML Backend | FastAPI + TensorFlow 2.21 |
| Market Data | yfinance + local S&P 500 CSVs |

## Getting Started

### Desktop Installers
StockD provides ready-to-use installers for multiple platforms:  
- Windows: `.exe`  
- macOS: `.dmg`  
- Linux: `.rpm` and `.deb`

1. Download the installer for your platform from the [releases page](https://github.com/eshi999/StockD/releases).  
2. Follow platform-specific instructions below.

### Flutter UI (Optional Build)
If you prefer to build from source (e.g., for development or contributions):

```bash
git clone https://github.com/eshi999/StockD.git
cd StockD
flutter pub get
flutter run -d <your-desktop-target>
```

**Note:** The UI expects the SAGE backend to be running at `http://localhost:8000`.

### SAGE ML Backend
**Prerequisites:** Python 3.12, internet connection (for initial data fetch)

1. Install dependencies:

```bash
pip install -r ML/requirements.txt
```

2. Configure ML settings:

```bash
python3.12 ML/ml_config.py
```

3. Optional: Fetch historical data and prepare for training (if you want to retrain SAGE):

```bash
python3.12 ML/fetch_sp500.py
python3.12 ML/prepare.py
python3.12 ML/train_sage.py
```

This will:
- Create `ML/historical/` with per-ticker CSVs.
- Prepare SAGE training data.
- Train the model (optional; pre-trained artifacts are included in `ML/artifacts/`).

4. Start the backend:

```bash
python3.12 -m uvicorn ML.main:app --host 0.0.0.0 --port 8000 --reload
```

5. Verify:

```bash
# Linux / macOS
curl http://localhost:8000/health

# Windows (PowerShell)
Invoke-WebRequest http://localhost:8000/health
```

Expected output:

```json
{ "status": "ok", "model_loaded": true }
```

6. Test SAGE:

```bash
curl -X POST http://localhost:8000/sage/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What is RSI?", "history": []}'
```

## Data Setup
StockD relies on **historical S&P 500 data** to reproduce SAGE explanations. **No raw data is distributed**; it is generated locally.

- To fetch data and optionally retrain SAGE, run:

```bash
python3.12 ML/ml_config.py
python3.12 ML/fetch_sp500.py
python3.12 ML/prepare.py  # optional if retraining
python3.12 ML/train_sage.py  # optional if retraining
```

**Disclaimer:** Historical stock data is provided by Yahoo Finance via yfinance. Data is fetched locally; no raw data is redistributed. StockD is an educational tool and does not provide financial advice.

## Installation Notes

### macOS — Gatekeeper
macOS will block the app on first open because it is not code-signed. To allow it:

1. Open **System Settings → Security & Privacy**.
2. You will see a message that StockD cannot be opened because it is from an unidentified developer.
3. Click **Open Anyway** and enter your password when prompted.

After this, StockD will open normally.

### Windows — UAC / SmartScreen
- Windows SmartScreen may show "Windows protected your PC"  
- Click **More info → Run anyway**  
- Click **Yes** at UAC prompt

### Linux — Package Installers
- Install `.deb` or `.rpm` packages:

```bash
# Debian / Ubuntu
sudo dpkg -i StockD.deb
sudo apt-get install -f

# Fedora / RHEL
sudo rpm -i StockD.rpm
```

## SAGE Philosophy
- SAGE is a **coach, not an autopilot**.  
- Explains concepts using plain language.  
- Anchors lessons to real S&P 500 tickers and historical price data.  
- Surfaces indicators (RSI, SMA, volatility) **as educational context only**.  
- Never gives buy/sell advice or predictions.

## Curriculum

| World | Topic | Difficulty |
|-------|-------|-----------|
| Market Basics | Stocks, exchanges, indices | Beginner |
| Reading the Tape | Charts, candlesticks, price action | Beginner |
| Fundamentals | Earnings, valuation, balance sheets | Intermediate |

Each world contains 5 levels of 20 questions each.

## Legal & Usage Notes
- StockD is for **educational and research purposes only**.  
- **No financial advice** is given. Always consult a licensed professional before making investment decisions.  
- Historical stock data is **fetched locally from Yahoo Finance via yfinance**; **no raw data is redistributed**.  
- **Usage restrictions:** This repository is not intended for commercial use, redistribution, or resale.

## Data & Git Notes
- GitHub rejects files over 100 MB; large files are excluded from the repo.  
- To reproduce the full data pipeline or retrain SAGE, run the provided scripts (`ML/ml_config.py`, `ML/fetch_sp500.py`, `ML/prepare.py`, `ML/train_sage.py`).  
- Data source: Yahoo Finance via yfinance.

