# StockD 📈

**Gamified stock market literacy — powered by a real AI coach.**

StockD is a desktop-first Flutter app that teaches stock market fundamentals through Duolingo-style progression, anchored to real S&P 500 data. It is **not** a trading tool, **not** a prediction engine, and **not** financial advice.

> *"SAGE explains. The user decides."*

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
  - [Flutter UI](#flutter-ui)
  - [SAGE ML Backend](#sage-ml-backend)
- [Installation Notes](#installation-notes)
  - [macOS — Gatekeeper](#macos--gatekeeper)
  - [Windows — UAC / SmartScreen](#windows--uac--smartscreen)
- [SAGE Philosophy](#sage-philosophy)
- [Curriculum](#curriculum)
- [Data & Git Notes](#data--git-notes)

---

## Overview

StockD combines gamified lesson progression with an AI coaching layer (SAGE) that explains concepts using real historical S&P 500 data. Users work through structured worlds and levels, answering multiple-choice questions. When they get something wrong, SAGE steps in — not to judge, but to explain *why*, using real charts and market data.

The Flutter app lives in `lib/` and is organized into models, providers, services, screens, and widgets. The Python ML backend (FastAPI + TensorFlow) lives in `ML/`, with data scripts and model artifacts kept separate from source.

---

## Features

- 🎮 **Duolingo-style progression** — Worlds → Levels → 20 questions each, with XP, streaks, and hearts
- 🤖 **SAGE AI Coach** — Explains wrong answers with real S&P 500 context and interactive charts
- 💬 **SAGE Chat** — Ask any stock market question at any time via an educational chatbot
- 📊 **Real market data** — Lessons reference actual tickers, RSI, SMA, volatility, and price history
- 🖥️ **Desktop-first** — Built with Flutter for Linux, macOS, and Windows
- ⚠️ **No financial advice** — Every AI response includes an explicit educational disclaimer

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | Flutter 3.x (Dart) |
| State Management | Riverpod 3.x |
| Navigation | GoRouter 17.x |
| Charts | fl_chart |
| Animations | flutter_animate |
| ML Backend | FastAPI + TensorFlow 2.21 |
| Market Data | yfinance + local S&P 500 CSVs |

---

## Getting Started

### Flutter UI

**Prerequisites:** Flutter 3.x, Dart SDK

```bash
git clone https://github.com/eshi999/StockD.git
cd StockD
flutter pub get
flutter run -d <your-desktop-target>
```

The UI expects the SAGE backend to be running at `http://localhost:8000`. See below.

---

### SAGE ML Backend

**Prerequisites:** Python 3.12, internet connection (for initial data fetch)

**1. Install dependencies**
```bash
pip install -r ML/requirements.txt
```

**2. Fetch S&P 500 data**
```bash
python3.12 ML/fetch_sp500.py
```
Populates `ML/historical/` with per-ticker CSVs.

**3. Start the backend**
```bash
python3.12 -m uvicorn ML.main:app --host 0.0.0.0 --port 8000 --reload
```

**4. Verify**
```bash
# Linux / macOS
curl http://localhost:8000/health

# Windows (PowerShell)
Invoke-WebRequest http://localhost:8000/health
```
Expected: `{ "status": "ok", "model_loaded": true }`

**5. Test SAGE**
```bash
curl -X POST http://localhost:8000/sage/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What is RSI?", "history": []}'
```

> **Optional — retrain the model:** Run `python3.12 ML/train_sage.py`. The pre-trained model in `ML/artifacts/` works for most users.

---

## Installation Notes

StockD is not code-signed. Both macOS and Windows will show a security warning on first launch — this is expected and safe to bypass.

### macOS — Gatekeeper

macOS will block the app on first open with a message like *"StockD cannot be opened because it is from an unidentified developer."*

**To open it:**

1. In Finder, locate `StockD.app`
2. Right-click (or Control-click) the app and select **Open**
3. Click **Open** in the dialog that appears

You only need to do this once. After that, the app opens normally.

Alternatively, via Terminal:
```bash
xattr -dr com.apple.quarantine /Applications/StockD.app
```

### Windows — UAC / SmartScreen

Windows SmartScreen may show *"Windows protected your PC"* when running the installer.

**To proceed:**

1. Click **More info** in the SmartScreen dialog
2. Click **Run anyway**

The UAC prompt that follows is standard for any installer that writes to `Program Files` — click **Yes** to continue.

---

## SAGE Philosophy

SAGE is a coach, not an autopilot.

- Explains *why* a concept matters using plain language
- Anchors lessons to real S&P 500 tickers and historical price data
- Surfaces indicators (RSI, SMA, volatility) **as educational context**, not signals
- **Never gives buy/sell advice or price predictions**
- Every response includes: *"⚠️ Educational information only, not financial advice."*

---

## Curriculum

| World | Topic | Difficulty |
|---|---|---|
| 🌿 Market Basics | Stocks, exchanges, indices | Beginner |
| 🏘️ Reading the Tape | Charts, candlesticks, price action | Beginner |
| 🏙️ Fundamentals | Earnings, valuation, balance sheets | Intermediate |

Each world contains 5 levels of 20 questions each.

---

## Data & Git Notes

GitHub rejects files over 100 MB. The following are excluded from the repo and must be regenerated locally:

| Path | How to regenerate |
|---|---|
| `ML/historical/` | `python3.12 ML/fetch_sp500.py` |
| `ML/artifacts/*.keras` | `python3.12 ML/train_sage.py` |
| `ML/sage_training_data.csv` | Generated during training |

All scripts needed to reproduce the full data pipeline are included in source.

---
