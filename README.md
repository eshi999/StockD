# StockD

**Gamified stock market literacy — powered by a local AI coach.**

StockD is a desktop-first educational platform that teaches stock market fundamentals through interactive progression, historical market data, and an integrated local AI mentor called **SAGE**.

Built for learning, exploration, and financial literacy, StockD transforms investing concepts into an engaging progression system while keeping users in complete control of their educational journey.

> **"SAGE explains. The user decides."**

---

# What Is StockD?

StockD combines:

* Duolingo-style progression
* Real historical market context
* Interactive AI-powered explanations
* Native desktop performance
* Fully local AI inference

Users advance through worlds and levels while learning:

* Stock market fundamentals
* Price charts and market structure
* Technical indicators
* Company fundamentals
* Market psychology and behavior
* Risk and volatility concepts

When users answer incorrectly, SAGE provides contextual explanations using historical market examples and educational insights.

StockD is designed to help users understand how markets work—not tell them what to buy, sell, or invest in.

---

# Integrated AI Runtime & Optimizations

StockD ships with a fully integrated, pre-compiled AI engine called **SAGE**. The runtime is compiled as a standalone sidecar binary using PyInstaller, stripped of debug overhead, and tailored with specific hardware optimizations across architectures.

When the application launches, it automatically spawns the local AI runtime as a background child process, initializes TensorFlow, and detects available hardware acceleration.

## Hardware Acceleration Matrix

| Platform Identifier  | Architecture | Backend Engine / Framework          | Acceleration Mechanism                  | Requirements                          |
| -------------------- | ------------ | ----------------------------------- | --------------------------------------- | ------------------------------------- |
| `windows-x64-nvidia` | x64          | TensorFlow 2.10.1                   | Direct CUDA Core Hooking                | NVIDIA Driver + CUDA 11.2 + cuDNN 8.1 |
| `windows-x64-intel`  | x64          | TensorFlow 2.10.1 + Intel Extension | Intel oneAPI / oneDNN                   | Intel Arc or Iris Xe                  |
| `windows-x64-amd`    | x64          | TensorFlow 2.10.1 Base              | AVX2 CPU Vector Optimization            | Standard CPU                          |
| `mac-arm`            | ARM64        | TensorFlow 3.x + tensorflow-metal   | Apple Metal Performance Shaders (MPS)   | Apple Silicon                         |
| `mac-intel`          | x64          | TensorFlow 3.x Base                 | AVX / AVX2 CPU Instructions             | Intel Mac                             |
| `linux-x64-nvidia`   | x64          | TensorFlow 3.x + Bundled CUDA       | Self-Contained CUDA / cuDNN v12 Runtime | NVIDIA Driver                         |
| `linux-x64-intel`    | x64          | TensorFlow 3.x + Intel Extension    | Intel oneDNN Optimizations              | Intel Hardware                        |
| `linux-x64-amd`      | x64          | TensorFlow 3.x Base                 | CPU Vectorization                       | Standard Linux                        |
| `linux-arm64`        | ARM64        | TensorFlow 3.x Base                 | AArch64 NEON SIMD                       | ARM64 Linux                           |

No Python installation, manual environment configuration, or command-line setup is required. Everything executes within the application bundle.

---

# Features

* Gamified learning progression
* XP, streaks, achievements, and hearts
* AI-powered educational coaching
* Interactive SAGE chatbot
* Historical market analysis
* RSI, SMA, trend, and volatility explanations
* Interactive charts and visualizations
* Hardware-accelerated local inference
* Native desktop performance
* Offline-capable architecture
* Windows, macOS, Linux, and ARM64 support

---

# Platform Downloads

StockD provides platform-specific installers optimized for each hardware environment.

## Windows (x64)

### NVIDIA GPUs

Optimized for dedicated NVIDIA GeForce and RTX hardware.

```text
StockD-windows-x64-nvidia-setup.exe
```

### AMD GPUs

Optimized for AMD Radeon-based systems.

```text
StockD-windows-x64-amd-setup.exe
```

### Intel Graphics / CPU Systems

Includes Intel Extension for TensorFlow acceleration.

```text
StockD-windows-x64-intel-setup.exe
```

> **Windows SmartScreen Notice**
> Because StockD bundles a complete local AI runtime, Windows may display:
>
> ```text
> Windows protected your PC
> ```
>
> Select:
>
> ```text
> More info → Run anyway
> ```

---

## macOS

### Apple Silicon (ARM64)

Native Apple Silicon build utilizing Metal acceleration.

```text
StockD-mac-arm.dmg
```

### Intel Macs

Legacy Intel x64 build.

```text
StockD-mac-intel.dmg
```

Installation:

```text
Drag StockD.app into /Applications
```

If Gatekeeper blocks execution:

1. Open **System Settings**
2. Navigate to **Privacy & Security**
3. Scroll to **Security**
4. Click **Open Anyway**

---

## Linux

### NVIDIA Systems

Self-contained CUDA runtime.

Artifacts:

```text
StockD-linux-x64-nvidia.deb
StockD-linux-x64-nvidia-1.2.0.rpm
```

### AMD Systems

Artifacts:

```text
StockD-linux-x64-amd.deb
StockD-linux-x64-amd-1.2.0.rpm
```

### Intel Systems

Artifacts:

```text
StockD-linux-x64-intel.deb
StockD-linux-x64-intel-1.2.0.rpm
```

### ARM64 Systems

Compiled natively for ARM64 Linux environments.

Artifacts:

```text
StockD-linux-arm64.deb
StockD-linux-arm64-1.2.0.rpm
```

### Debian / Ubuntu / Mint

```bash
sudo dpkg -i stockd-linux-*.deb
sudo apt-get install -f
```

### Fedora / RHEL / CentOS

```bash
sudo rpm -i stockd-linux-*.rpm
```

---

# Technology Stack

| Layer            | Technology           | Implementation Details               |
| ---------------- | -------------------- | ------------------------------------ |
| UI Rendering     | Flutter 3.x          | Native canvas-rendered desktop UI    |
| State Management | Riverpod             | Reactive state architecture          |
| Navigation       | GoRouter             | Declarative route management         |
| Charts           | fl_chart             | High-performance financial charting  |
| Animation        | flutter_animate      | Gamification and progression effects |
| AI Runtime       | FastAPI + TensorFlow | Local AI sidecar engine              |
| Data Source      | Historical Datasets  | Bundled S&P 500 educational datasets |

---

# Architecture

StockD uses a sidecar-assisted desktop architecture designed for local AI execution.

```text
[ Flutter Desktop UI Application ]
               │  ▲
  Localhost    │  │  JSON Messages
  loopback API │  │  (HTTP / WebSockets)
               ▼  │
 [ SAGE AI Sidecar Engine ]
   (Python + TensorFlow)
```

## Frontend

The Flutter frontend manages:

* Rendering
* Navigation
* Charts
* Progression systems
* XP and streak tracking
* Animations
* User interaction

## SAGE AI Engine

The SAGE sidecar engine manages:

* Educational explanations
* Historical market analysis
* Technical indicator interpretation
* Machine learning inference
* Context-aware tutoring

## Communication Layer

Flutter and SAGE communicate through localhost APIs using JSON messages.

Benefits include:

* Low latency
* Process isolation
* Hardware acceleration
* Fault containment
* Offline operation
* Cross-platform portability

### Runtime Data Storage

Persistent runtime data is stored using native user-space locations:

**Windows**

```text
%APPDATA%\StockD\
```

**Linux**

```text
~/.config/stockd/
```

**macOS**

```text
~/Library/Application Support/StockD/
```

No administrator privileges are required.

---

# Curriculum

## World 1 — Market Basics

**Concepts**

* Equity ownership
* Order books
* Exchanges
* Market indices

**Difficulty:** Beginner

---

## World 2 — Reading the Tape

**Concepts**

* Candlesticks
* Price action
* Support and resistance
* Trend analysis

**Difficulty:** Beginner

---

## World 3 — Fundamentals

**Concepts**

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
* Dynamic AI explanations powered by SAGE

Additional worlds are planned.

---

# SAGE Philosophy

SAGE is designed as an educational coach.

### SAGE Is

* A teacher
* A coach
* An explainer
* A learning companion

### SAGE Is Not

* A financial advisor
* A stock recommendation engine
* A trading bot
* A prediction system
* An autonomous portfolio manager

SAGE exists solely to improve financial literacy.

---

# Privacy & Local Processing

StockD follows a local-first privacy model.

* All machine learning models execute locally.
* User interactions remain on-device.
* No cloud AI APIs are required.
* No subscription services are required.
* Full functionality is available offline.

This architecture provides both privacy and low-latency educational experiences.

---

# Legal Notice

StockD is provided solely for educational and research purposes.

* StockD does not provide financial advice.
* StockD does not provide investment recommendations.
* StockD does not generate actionable buy/sell signals.
* Historical market datasets are used exclusively for educational explanations.
* Users should consult licensed financial professionals before making investment decisions.

**StockD is an educational learning platform—not a trading platform.**
