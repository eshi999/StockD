# StockD

<div align="center">

### Gamified Stock Market Literacy — Powered by a Local AI Coach

Learn how markets work through interactive lessons, historical data, and an on-device AI mentor.

**"SAGE explains. The user decides."**

---

![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue)
![AI](https://img.shields.io/badge/AI-Local%20Inference-green)
![Offline](https://img.shields.io/badge/Offline-Capable-success)
![Flutter](https://img.shields.io/badge/Built%20With-Flutter-02569B)

</div>

---

## Overview

StockD is a desktop-first educational platform designed to teach stock market fundamentals through gamified progression, real historical market context, and a fully local AI tutor called **SAGE**.

Instead of focusing on stock picks or trading signals, StockD focuses on understanding:

* How markets function
* Why prices move
* How investors evaluate companies
* Market psychology and risk
* Technical and fundamental analysis concepts

Users progress through structured learning worlds while receiving contextual explanations from SAGE whenever they need help.

> StockD teaches market literacy—not investment advice.

---

## Why StockD?

Most investing apps assume users already understand financial markets.

StockD takes a different approach.

### Learn Through Progression

Inspired by modern learning platforms, StockD transforms financial education into an interactive journey featuring:

* XP and progression systems
* Streak tracking
* Hearts and challenge mechanics
* Unlockable learning worlds
* Achievement-based progression

### Learn With Context

Rather than abstract definitions, concepts are taught using:

* Historical market examples
* Real-world scenarios
* Interactive chart analysis
* Contextual explanations

### Learn Privately

All AI processing happens locally on your machine.

No cloud AI services.
No subscriptions.
No data collection required.

---

## Features

### Educational Experience

* Structured learning curriculum
* Progressive difficulty levels
* Interactive quizzes
* Historical market examples
* Dynamic explanations
* AI-assisted tutoring

### SAGE AI Mentor

* Context-aware explanations
* Technical indicator guidance
* Market behavior insights
* Historical event analysis
* Interactive chatbot interface

### Market Concepts Covered

* Market structure
* Exchanges and order books
* Candlestick analysis
* Support and resistance
* Trends and momentum
* Volatility concepts
* Company fundamentals
* Financial statements
* Valuation metrics
* Investor psychology

### Platform Features

* Native desktop experience
* Hardware-accelerated AI inference
* Offline-capable architecture
* Cross-platform support
* Local-first design
* No external AI APIs

---

## Screenshots

> Screenshots and demos coming soon.

Suggested images:

* Dashboard
* Learning World Selection
* Quiz Interface
* SAGE Chat Assistant
* Market Chart Analysis
* Achievement System

---

## How SAGE Works

SAGE is StockD's integrated educational AI engine.

When users encounter difficult concepts, answer questions incorrectly, or request clarification, SAGE provides explanations using:

* Historical market context
* Educational examples
* Technical analysis concepts
* Fundamental analysis concepts
* Guided reasoning

### SAGE Is

✅ A teacher

✅ A coach

✅ An explainer

✅ A learning companion

### SAGE Is Not

❌ A financial advisor

❌ A stock recommendation engine

❌ A trading bot

❌ A prediction system

❌ An autonomous portfolio manager

---

## Local AI Runtime

StockD includes a fully integrated AI runtime distributed alongside the application.

At launch, StockD automatically:

1. Starts the SAGE sidecar process
2. Initializes TensorFlow
3. Detects available hardware acceleration
4. Loads educational AI models
5. Establishes local communication channels

No additional setup is required.

Users do not need to install:

* Python
* CUDA Toolkits
* TensorFlow
* AI frameworks
* External dependencies

Everything ships with the application.

---

## Hardware Acceleration

| Platform            | Architecture | Acceleration         |
| ------------------- | ------------ | -------------------- |
| Windows NVIDIA      | x64          | CUDA                 |
| Windows Intel       | x64          | oneDNN / oneAPI      |
| Windows AMD         | x64          | AVX2                 |
| macOS Apple Silicon | ARM64        | Metal (MPS)          |
| macOS Intel         | x64          | AVX / AVX2           |
| Linux NVIDIA        | x64          | Bundled CUDA Runtime |
| Linux Intel         | x64          | oneDNN               |
| Linux AMD           | x64          | CPU Vectorization    |
| Linux ARM64         | ARM64        | NEON SIMD            |

---

## Architecture

```text
┌─────────────────────────┐
│  Flutter Desktop Client │
└───────────┬─────────────┘
            │
            │ JSON / HTTP / WebSockets
            │
┌───────────▼─────────────┐
│     SAGE AI Engine      │
│  Python + TensorFlow    │
└─────────────────────────┘
```

### Frontend

Responsible for:

* Rendering
* Navigation
* Progression systems
* Charts and visualizations
* XP and achievements
* User interaction

### AI Sidecar

Responsible for:

* Educational explanations
* Market analysis
* Context management
* Local inference
* Technical indicator interpretation

### Benefits

* Low latency
* Process isolation
* Hardware acceleration
* Fault containment
* Offline operation
* Cross-platform portability

---

## Technology Stack

| Layer            | Technology                 |
| ---------------- | -------------------------- |
| UI Framework     | Flutter 3.x                |
| State Management | Riverpod                   |
| Navigation       | GoRouter                   |
| Charts           | fl_chart                   |
| Animations       | flutter_animate            |
| AI Runtime       | FastAPI                    |
| Machine Learning | TensorFlow                 |
| Data Source      | Historical Market Datasets |

---

## Curriculum

### World 1 — Market Basics

**Topics**

* Equity ownership
* Exchanges
* Order books
* Market indices

**Difficulty:** Beginner

---

### World 2 — Reading the Tape

**Topics**

* Candlesticks
* Price action
* Trend analysis
* Support and resistance

**Difficulty:** Beginner

---

### World 3 — Fundamentals

**Topics**

* Earnings reports
* Valuation metrics
* Income statements
* Balance sheets
* Financial analysis

**Difficulty:** Intermediate

---

Each world currently contains:

* 5 Levels
* 10 Questions per Level
* Dynamic AI explanations

Additional worlds are planned.

---

## Data Storage

StockD stores application data in standard user-space locations.

### Windows

```text
%APPDATA%\StockD\
```

### Linux

```text
~/.config/stockd/
```

### macOS

```text
~/Library/Application Support/StockD/
```

No administrator privileges are required.

---

## Privacy

StockD follows a local-first privacy model.

### Local Processing

* AI models run locally
* User data remains on-device
* No cloud inference
* No external AI APIs
* Offline functionality available

### User Control

* No mandatory accounts
* No subscription requirement
* No remote model dependency

---

## Downloads

Platform-specific installers are provided for:

* Windows x64
* macOS Apple Silicon
* macOS Intel
* Linux x64 NVIDIA
* Linux x64 AMD
* Linux x64 Intel
* Linux ARM64

Some distributions include bundled AI models and acceleration libraries that exceed standard hosting limits and may be distributed as split archives.

See release notes for platform-specific installation instructions.

---

## Roadmap

### Planned Features

* Additional learning worlds
* Advanced technical analysis curriculum
* Options and derivatives education
* Expanded historical datasets
* Achievement expansion
* Community challenge modes
* Enhanced AI tutoring capabilities

---

## Disclaimer

StockD is provided for educational and research purposes only.

StockD:

* Does not provide financial advice
* Does not provide investment recommendations
* Does not generate buy/sell signals
* Does not manage portfolios
* Does not predict market outcomes

Historical market data is used exclusively for educational explanations.

Users should consult licensed financial professionals before making investment decisions.

---

## License

License information coming soon.

---

<div align="center">

### Learn the market. Understand the why.

**StockD — Financial literacy powered by local AI.**

</div>
