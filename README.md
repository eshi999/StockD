# StockD
Gamified stock market literacy — powered by a real AI coach.

StockD is a desktop-first Flutter app that teaches stock market fundamentals through Duolingo-style progression, anchored to **historical S&P 500 data**. It is **not a trading tool, not a prediction engine, and not financial advice.**

> "SAGE explains. The user decides."

## Overview
StockD combines gamified lesson progression with an AI coaching layer (SAGE) that explains concepts using **historical S&P 500 data**. Users progress through worlds and levels, answering multiple-choice questions. When they get something wrong, SAGE explains why using real charts and market data — **educational only**.

The Flutter app lives in `lib/` and is organized into models, providers, services, screens, and widgets. The Python ML backend (FastAPI + TensorFlow) lives in `ML/`, with data scripts and model artifacts kept separate from source.

## Features
- Duolingo-style progression — Worlds → Levels → 10 questions each, with XP, streaks, and hearts
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
- macOS: `StockD.app`
- Linux: `.rpm` and `.deb`

Download the release for your platform from the [releases page](https://github.com/eshi999/StockD/releases) and follow the platform-specific instructions below.

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
cd ML
python3.12 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
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

To fetch data and optionally retrain SAGE, run:

```bash
python3.12 ML/ml_config.py
python3.12 ML/fetch_sp500.py
python3.12 ML/prepare.py  # optional if retraining
python3.12 ML/train_sage.py  # optional if retraining
```

**Disclaimer:** Historical stock data is provided by Yahoo Finance via yfinance. Data is fetched locally; no raw data is redistributed. StockD is an educational tool and does not provide financial advice.

## Installation Notes

### macOS
The macOS release is `StockD.app` — a self-contained application bundle.

**To install:**
1. Download `StockD.app` from the releases page.
2. Move `StockD.app` into your **Applications** folder:
   - Open Finder, go to **Applications**, and drag `StockD.app` in.
   - Or via Terminal: `mv ~/Downloads/StockD.app /Applications/`
3. Launch StockD from **Applications** or Spotlight.

**Gatekeeper — first launch:**

Because StockD is not code-signed with an Apple Developer certificate, macOS will block it on first open with the message *"StockD.app cannot be opened because it is from an unidentified developer."*

To allow it:
1. Open **System Settings → Privacy & Security**.
2. Scroll down to the **Security** section — you will see a message that StockD was blocked.
3. Click **Open Anyway**.
4. Enter your password when prompted.
5. Click **Open** on the confirmation dialog.

StockD will open normally on all subsequent launches.

Alternatively, you can bypass Gatekeeper from Terminal before moving the app:
```bash
xattr -cr ~/Downloads/StockD.app
```
Then move it to Applications and open normally.

### Windows
- Windows SmartScreen may show "Windows protected your PC"
- Click **More info → Run anyway**
- Click **Yes** at the UAC prompt

### Linux
Install via package manager:

```bash
# Debian / Ubuntu
sudo dpkg -i stockd-linux-x64.deb
sudo apt-get install -f

# Fedora / RHEL
sudo rpm -i stockd-linux-x64.rpm
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

Each world contains 5 levels of 10 questions each.

## Legal & Usage Notes
- StockD is for **educational and research purposes only**.
- **No financial advice** is given. Always consult a licensed professional before making investment decisions.
- Historical stock data is **fetched locally from Yahoo Finance via yfinance**; **no raw data is redistributed**.
- **Usage restrictions:** This repository is not intended for commercial use, redistribution, or resale.
