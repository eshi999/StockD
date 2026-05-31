# StockD

> **Gamified stock market literacy — powered by a local AI coach.**

StockD is a desktop-first educational platform that teaches stock market fundamentals through interactive progression, historical market data, and an integrated local AI mentor called **SAGE**.

Built for learning, exploration, and financial literacy, StockD transforms investing concepts into an engaging progression system while keeping users in complete control of their educational journey.

> **"SAGE explains. The user decides."**

---

# What Is StockD?

StockD combines:

* Gamified progression inspired by modern learning platforms
* Real historical market context
* Interactive AI-powered explanations
* Native desktop performance
* Fully local AI inference

Users advance through structured worlds and levels while learning:

* Stock market fundamentals
* Price charts and market structure
* Technical indicators
* Company fundamentals
* Market psychology and behavior
* Risk and volatility concepts

When users answer incorrectly, SAGE provides contextual explanations using historical market examples and educational insights.

**StockD is designed to help users understand how markets work—not tell them what to buy, sell, or invest in.**

---

# Integrated AI Runtime

StockD ships with a fully integrated local AI engine called **SAGE**.

SAGE is packaged directly with the application and launches automatically during startup. The runtime initializes TensorFlow and configures available hardware acceleration for the host platform.

No Python installation, package management, virtual environments, or command-line setup is required.

Everything runs directly from the application bundle.

---

## Hardware Acceleration Matrix

| Platform            | Architecture | Runtime                           | Acceleration                          |
| ------------------- | ------------ | --------------------------------- | ------------------------------------- |
| Windows x64         | x64          | TensorFlow 2.10.1                 | AVX / AVX2 CPU Vectorization          |
| macOS Apple Silicon | ARM64        | TensorFlow 3.x + tensorflow-metal | Apple Metal Performance Shaders (MPS) |
| macOS Intel         | x64          | TensorFlow 3.x                    | AVX / AVX2 CPU Instructions           |
| Linux NVIDIA        | x64          | TensorFlow 3.x + Bundled CUDA     | Self-Contained CUDA / cuDNN Runtime   |
| Linux Intel         | x64          | TensorFlow 3.x + Intel Extension  | Intel oneDNN Optimizations            |
| Linux AMD           | x64          | TensorFlow 3.x                    | CPU Vectorization                     |
| Linux ARM64         | ARM64        | TensorFlow 3.x                    | AArch64 NEON SIMD                     |

---

# Features

## Learning & Progression

* XP progression system
* Daily streaks
* Achievements and milestones
* Heart-based challenge mechanics
* Structured educational worlds

## AI-Powered Coaching

* Interactive SAGE chatbot
* Context-aware explanations
* Historical market examples
* Technical indicator education
* Adaptive tutoring experiences

## Market Education

* Historical market analysis
* RSI, SMA, trend, and volatility explanations
* Company fundamentals
* Market psychology concepts
* Risk management education

## Platform Capabilities

* Native desktop performance
* Fully local AI inference
* Offline-capable architecture
* Cross-platform support
* Hardware-accelerated execution

---

# Downloads

StockD provides platform-specific installers optimized for desktop environments.

> **Important:** Some distributions exceed GitHub's file-size limitations due to bundled AI models and runtime dependencies. Large packages may be distributed as multiple archive segments.

---

## Windows

### Universal x64 Installer

```text
StockD-windows-x64-setup.exe
```

Supports all modern 64-bit versions of Windows.

### Windows SmartScreen

Because StockD bundles a complete local AI runtime, Windows may display:

```text
Windows protected your PC
```

To continue:

```text
More Info → Run Anyway
```

---

## macOS

### Apple Silicon (M-Series)

```text
StockD-mac-arm64.dmg
```

### Intel Macs

```text
StockD-mac-intel.dmg
```

### Installation

```text
Drag StockD.app into /Applications
```

### Gatekeeper & First Launch

Because StockD includes a bundled AI runtime and supporting binaries, macOS may block execution on first launch.

If StockD does not open:

```text
System Settings
→ Privacy & Security
→ Open Anyway
```

If the application is still blocked, remove macOS quarantine attributes:

```bash
xattr -cr /Applications/StockD.app
```

Then launch normally:

```bash
open /Applications/StockD.app
```

---

## Linux

### NVIDIA Systems

Large CUDA-enabled packages may be distributed in multiple archive segments.

```bash
cat StockD-linux-x64-nvidia.deb.part_* \
> StockD-linux-x64-nvidia.deb
```

### AMD Systems

```text
StockD-linux-x64-amd.deb
StockD-linux-x64-amd.rpm
```

### Intel Systems

```text
StockD-linux-x64-intel.deb
StockD-linux-x64-intel.rpm
```

### ARM64 Systems

```text
StockD-linux-arm64.deb
StockD-linux-arm64.rpm
```

### Debian / Ubuntu

```bash
sudo dpkg -i StockD-linux-*.deb
sudo apt-get install -f
```

### Fedora / RHEL

```bash
sudo rpm -i StockD-linux-*.rpm
```

---

# Technology Stack

| Layer            | Technology                 |
| ---------------- | -------------------------- |
| UI Framework     | Flutter 3.x                |
| State Management | Riverpod                   |
| Navigation       | GoRouter                   |
| Charting         | fl_chart                   |
| Animation        | flutter_animate            |
| AI Runtime       | FastAPI + TensorFlow       |
| Data Source      | Historical Market Datasets |

---

# Architecture

```text
[ Flutter Desktop Application ]
               │
               │ JSON Messages
               │ HTTP / WebSockets
               ▼
      [ SAGE AI Engine ]
     (Python + TensorFlow)
```

## Frontend Responsibilities

* UI rendering
* Navigation
* Interactive charts
* XP progression
* Achievement tracking
* User interaction

## SAGE Responsibilities

* Educational explanations
* Historical market analysis
* Technical indicator interpretation
* Local machine learning inference
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

---

# Windows Networking Permissions

StockD uses a local client-server architecture.

The desktop application and SAGE run as separate processes and communicate through localhost networking using HTTP and WebSocket connections.

Because SAGE hosts a local API service, Windows may display a firewall or networking permission prompt during first launch.

### Why This Permission Is Requested

The permission is required solely for communication between:

```text
StockD Desktop Application
        ↔
SAGE Local AI Engine
```

This connection enables:

* AI tutoring requests
* Educational explanations
* Historical market analysis
* Real-time communication
* Progression-related AI interactions

### Localhost Only

StockD communicates through:

```text
127.0.0.1 (localhost)
```

Communication remains entirely on the local machine and is not exposed to external devices.

### Firewall Guidance

If Windows requests permission, allowing access on:

```text
Private Networks
```

is sufficient for normal operation.

Public network access is not required.

---

# Runtime Data Storage

StockD stores application data using native user-space directories.

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

# Curriculum

## World 1 — Market Basics

**Topics**

* Equity ownership
* Order books
* Exchanges
* Market indices

**Difficulty:** Beginner

---

## World 2 — Reading the Tape

**Topics**

* Candlesticks
* Price action
* Support and resistance
* Trend analysis

**Difficulty:** Beginner

---

## World 3 — Fundamentals

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
* Dynamic AI-generated explanations from SAGE

Additional worlds are planned.

---

# SAGE Philosophy

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

StockD follows a local-first architecture.

* All AI models execute locally
* User interactions remain on-device
* No cloud AI services are required
* No subscriptions are required
* Full functionality is available offline

This architecture prioritizes privacy, ownership, and low-latency educational experiences.

---

# Legal Notice

StockD is provided solely for educational and research purposes.

* StockD does not provide financial advice.
* StockD does not provide investment recommendations.
* StockD does not generate actionable buy/sell signals.
* Historical market data is used exclusively for educational explanations.
* Users should consult licensed financial professionals before making investment decisions.

**StockD is an educational learning platform—not a trading platform.**
