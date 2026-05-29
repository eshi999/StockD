# StockD

**Gamified stock market literacy — powered by a local AI coach.**

StockD is a desktop-first educational application that teaches stock market fundamentals through interactive progression, real historical market data, and an integrated AI coaching system called **SAGE**.

StockD is designed for:

* learning
* experimentation
* financial literacy

It is **not**:

* a trading platform
* a prediction engine
* financial advice

> **"SAGE explains. The user decides."**

---

# What Is StockD?

StockD combines:

* Duolingo-style progression
* Real S&P 500 historical context
* Interactive AI explanations
* Native desktop performance
* Fully local AI inference

Users progress through worlds and levels while learning:

* stock market basics
* chart interpretation
* technical indicators
* fundamentals
* market behavior

When a user answers incorrectly, SAGE explains the concept using historical market examples and educational context.

---

# Integrated AI Runtime

StockD includes a fully integrated AI backend called **SAGE**.

When the application launches, it automatically:

* Starts the local AI runtime
* Initializes TensorFlow
* Loads educational market-analysis models
* Connects to available GPU acceleration
* Establishes local communication with the Flutter UI

No separate terminal, Python setup, or backend management is required.

All inference runs locally on-device.

---

# Features

* Duolingo-style progression system
* XP, streaks, and hearts
* AI-powered educational coaching
* Interactive SAGE chatbot
* Historical S&P 500 market context
* RSI, SMA, volatility, and trend analysis
* Interactive charts and explanations
* GPU-accelerated local inference
* Native desktop experience
* Offline-capable architecture
* Windows, macOS, and Linux support

---

# Technology Stack

| Layer            | Technology                  |
| ---------------- | --------------------------- |
| UI               | Flutter 3.x                 |
| State Management | Riverpod                    |
| Navigation       | GoRouter                    |
| Charts           | fl_chart                    |
| Animation        | flutter_animate             |
| AI Runtime       | FastAPI + TensorFlow        |
| Data Source      | Historical S&P 500 datasets |

---

# Installation

## Windows

Download the `.exe` installer from the Releases page and run normally.

Windows SmartScreen may display:

```text id="v0g8x4"
Windows protected your PC
```

Choose:

```text id="w5f5az"
More info → Run anyway
```

---

## macOS

Download:

```text id="guk4gf"
StockD.app
```

Move it into:

```text id="h8ozqr"
/Applications
```

On first launch, macOS Gatekeeper may block execution because the app is not yet signed with an Apple Developer certificate.

To allow execution:

1. Open:

   * System Settings → Privacy & Security
2. Scroll to:

   * Security
3. Click:

   * Open Anyway

---

## Linux

Install using your package manager.

### Debian / Ubuntu

```bash id="vrb7tp"
sudo dpkg -i stockd-linux-x64.deb
sudo apt-get install -f
```

### Fedora / RHEL

```bash id="1y8wyw"
sudo rpm -i stockd-linux-x64.rpm
```

---

# Architecture

StockD uses a sidecar-assisted desktop architecture.

## Frontend

Flutter handles:

* rendering
* animations
* progression systems
* charts
* user interaction

## SAGE AI Engine

SAGE handles:

* educational explanations
* market context analysis
* technical indicator interpretation
* historical data processing

## Communication Layer

Flutter and SAGE communicate locally through internal JSON APIs over localhost.

This architecture provides:

* low latency
* local inference
* hardware acceleration
* strong process isolation
* cross-platform portability

---

# SAGE Philosophy

SAGE is designed as:

* a coach
* a teacher
* an explainer

SAGE is intentionally **not**:

* a financial advisor
* a prediction engine
* an autonomous trading system

All explanations are educational-only.

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

# Legal Notice

StockD is provided for educational and research purposes only.

* No financial advice is provided.
* Historical market data is used strictly for educational explanations.
* Users should consult licensed financial professionals before making investment decisions.
* StockD does not provide buy/sell recommendations or investment predictions.
