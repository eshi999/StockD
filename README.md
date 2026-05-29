# StockD

**Gamified stock market literacy — powered by a real AI coach.**

StockD is a desktop-first Flutter application that teaches stock market fundamentals through Duolingo-style progression, powered by a locally running AI coaching system called **SAGE**.

It is built around **historical S&P 500 market data** and is designed strictly for **education and research** — **not trading, not prediction, and not financial advice.**

> **"SAGE explains. The user decides."**

---

# Overview

StockD combines:

* Gamified lesson progression
* Real historical market context
* Interactive educational explanations
* A locally hosted AI sidecar backend

Users advance through worlds and levels by answering multiple-choice questions covering market fundamentals, technical indicators, and financial literacy concepts.

When a question is answered incorrectly, **SAGE** analyzes the context using historical market data and explains:

* Why the answer was incorrect
* What the indicator or concept means
* How the market behaved historically in similar conditions

All explanations are educational-only and never provide buy/sell recommendations.

---

# Architecture

StockD uses a **desktop sidecar architecture**:

| Component        | Stack                             |
| ---------------- | --------------------------------- |
| Desktop UI       | Flutter 3.x + Dart                |
| State Management | Riverpod 3.x                      |
| Navigation       | GoRouter 17.x                     |
| Charts           | fl_chart                          |
| Animation        | flutter_animate                   |
| AI Backend       | FastAPI + TensorFlow 2.21         |
| Market Data      | yfinance + local S&P 500 datasets |

## SAGE Integration

SAGE is deeply integrated into the desktop runtime rather than launched manually.

### Integrated Backend Lifecycle

The Flutter desktop application automatically:

* Starts the FastAPI backend via `Process.start`
* Launches SAGE inside a dedicated Conda environment
* Attaches TensorFlow to available GPU hardware
* Monitors backend readiness before enabling UI requests

### Asynchronous Health Synchronization

StockD continuously polls the local backend during startup to ensure:

* TensorFlow has fully initialized
* GPU memory allocation is complete
* Model artifacts are loaded
* The API is ready before requests are sent

This prevents frontend race conditions during cold starts.

### Cross-Language Runtime Communication

Flutter and Python communicate through local JSON APIs:

* Dart sends lesson context and market metadata
* Python calculates indicators and explanation context
* SAGE streams educational responses back into the UI

### Environment Isolation

The entire ML stack executes inside an isolated Conda environment, preventing conflicts with:

* System Python packages
* Native Linux libraries
* TensorFlow CUDA dependencies

This keeps the host development environment stable and reproducible.

---

# Features

* Duolingo-style progression system
* XP, streaks, hearts, and level progression
* AI-powered educational coaching
* Interactive SAGE chatbot
* Historical S&P 500 explanations
* RSI, SMA, volatility, and trend analysis
* Native desktop experience
* Linux, macOS, and Windows support
* Fully local backend execution
* GPU acceleration support
* Explicit educational disclaimers in all AI responses

---

# Repository Structure

```text
lib/                Flutter application source
  models/
  providers/
  screens/
  services/
  widgets/

ML/                 Python AI backend
  artifacts/        Trained model artifacts
  historical/       Generated market datasets
  main.py           FastAPI entrypoint
  train_sage.py     Training pipeline
  fetch_sp500.py    Historical data fetcher
```

---

# Getting Started

## Prebuilt Desktop Installers

StockD ships with platform-native installers:

| Platform | Package         |
| -------- | --------------- |
| Windows  | `.exe`          |
| macOS    | `StockD.app`    |
| Linux    | `.deb` / `.rpm` |

Download the latest release from the GitHub Releases page.

---

# Running From Source

## 1. Clone Repository

```bash
git clone https://github.com/eshi999/StockD.git
cd StockD
```

---

# Flutter Frontend Setup

```bash
flutter pub get
flutter run -d <desktop-target>
```

Supported targets:

* linux
* windows
* macos

---

# SAGE Backend Setup

## Prerequisites

* Python 3.12
* Conda or Miniconda
* Internet connection (initial historical data fetch)

---

## Install Dependencies

```bash
pip install -r ML/requirements.txt
```

---

## Configure ML Environment

```bash
python3.12 ML/ml_config.py
```

---

## Optional: Fetch Data + Retrain SAGE

```bash
python3.12 ML/fetch_sp500.py
python3.12 ML/prepare.py
python3.12 ML/train_sage.py
```

This process:

* Downloads historical S&P 500 datasets
* Generates training features
* Prepares educational explanation context
* Retrains the TensorFlow model

Pretrained artifacts are already included in:

```text
ML/artifacts/
```

---

## Start Backend Manually (Optional)

StockD normally launches SAGE automatically.

For standalone backend development:

```bash
cd ML
python3.12 -m uvicorn main:app --port 8000 --reload
```

---

# Verify Backend

## Linux / macOS

```bash
curl http://localhost:8000/health
```

## Windows PowerShell

```powershell
Invoke-WebRequest http://localhost:8000/health
```

Expected response:

```json
{
  "status": "ok",
  "model_loaded": true
}
```

---

# Test SAGE

```bash
curl -X POST http://localhost:8000/sage/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"What is RSI?","history":[]}'
```

---

# Data Pipeline

StockD relies entirely on **historical market data**.

No raw stock datasets are redistributed.

Data is fetched locally through Yahoo Finance using `yfinance`.

To regenerate datasets:

```bash
python3.12 ML/ml_config.py
python3.12 ML/fetch_sp500.py
```

Optional retraining:

```bash
python3.12 ML/prepare.py
python3.12 ML/train_sage.py
```

---

# Installation Notes

## macOS

The macOS release is distributed as:

```text
StockD.app
```

Move the application into:

```text
/Applications
```

### Gatekeeper Warning

Because StockD is not currently signed with an Apple Developer certificate, macOS may block the first launch.

To allow execution:

1. Open:

   * System Settings → Privacy & Security
2. Scroll to:

   * Security
3. Click:

   * Open Anyway

Alternative terminal bypass:

```bash
xattr -cr ~/Downloads/StockD.app
```

---

## Windows

Windows SmartScreen may display:

```text
Windows protected your PC
```

Choose:

```text
More info → Run anyway
```

---

## Linux

### Debian / Ubuntu

```bash
sudo dpkg -i stockd-linux-x64.deb
sudo apt-get install -f
```

### Fedora / RHEL

```bash
sudo rpm -i stockd-linux-x64.rpm
```

---

# SAGE Philosophy

SAGE is intentionally designed as:

* A coach
* A teacher
* A contextual explainer

SAGE is **not**:

* A trading bot
* A prediction engine
* A financial advisor
* An automated investing system

The AI exists solely to improve financial literacy through historical examples and contextual explanations.

---

# Curriculum

| World            | Topic                               | Difficulty   |
| ---------------- | ----------------------------------- | ------------ |
| Market Basics    | Stocks, exchanges, indices          | Beginner     |
| Reading the Tape | Charts, candlesticks, price action  | Beginner     |
| Fundamentals     | Earnings, valuation, balance sheets | Intermediate |

Each world contains:

* 5 levels
* 10 questions per level

Additional worlds are planned.

---

# Legal & Usage Notes

* StockD is for educational and research purposes only.
* No financial advice is provided.
* Always consult a licensed financial professional before making investment decisions.
* Historical market data is fetched locally using Yahoo Finance via `yfinance`.
* No raw market datasets are redistributed.
* This repository is not intended for commercial resale or redistribution.

---

# Future Goals

* Expanded curriculum worlds
* Interactive chart drawing lessons
* Portfolio simulation sandbox
* Achievement systems
* Offline inference support
* Additional ML explanation models
* Native mobile companion experience

---

# License

See repository license for details.
