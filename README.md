ownloads section to reflect your new, streamlined universal Windows build.
StockD

Gamified stock market literacy — powered by a local AI coach.

StockD is a desktop-first educational platform that teaches stock market fundamentals through interactive progression, historical market data, and an integrated local AI mentor called SAGE.

Built for learning, exploration, and financial literacy, StockD transforms investing concepts into an engaging progression system while keeping users in complete control of their educational journey.

    "SAGE explains. The user decides."

What Is StockD?

StockD combines:

    Duolingo-style progression

    Real historical market context

    Interactive AI-powered explanations

    Native desktop performance

    Fully local AI inference

Users advance through worlds and levels while learning:

    Stock market fundamentals

    Price charts and market structure

    Technical indicators

    Company fundamentals

    Market psychology and behavior

    Risk and volatility concepts

When users answer incorrectly, SAGE provides contextual explanations using historical market examples and educational insights.

StockD is designed to help users understand how markets work—not tell them what to buy, sell, or invest in.
Integrated AI Runtime & Optimizations

StockD ships with a fully integrated, pre-compiled AI engine called SAGE. The runtime is compiled as a standalone sidecar binary using PyInstaller, stripped of debug overhead, and tailored with specific hardware optimizations across architectures.

When the application launches, it automatically spawns the local AI runtime as a background child process, initializes TensorFlow, and detects available hardware acceleration.
Hardware Acceleration Matrix
Platform Identifier	Architecture	Backend Engine / Framework	Acceleration Mechanism	Requirements
windows-x64	x64	TensorFlow 2.10.1 Base	AVX / AVX2 CPU Vectorization	Standard Windows CPU
mac-arm	ARM64	TensorFlow 3.x + tensorflow-metal	Apple Metal Performance Shaders (MPS)	Apple Silicon
mac-intel	x64	TensorFlow 3.x Base	AVX / AVX2 CPU Instructions	Intel Mac
linux-x64-nvidia	x64	TensorFlow 3.x + Bundled CUDA	Self-Contained CUDA / cuDNN v12 Runtime	NVIDIA Driver
linux-x64-intel	x64	TensorFlow 3.x + Intel Extension	Intel oneDNN Optimizations	Intel Hardware
linux-x64-amd	x64	TensorFlow 3.x Base	CPU Vectorization	Standard Linux CPU
linux-arm64	ARM64	TensorFlow 3.x Base	AArch64 NEON SIMD	ARM64 Linux

No Python installation, manual environment configuration, or command-line setup is required. Everything executes within the application bundle.
Features

    Gamified learning progression

    XP, streaks, achievements, and hearts

    AI-powered educational coaching

    Interactive SAGE chatbot

    Historical market analysis

    RSI, SMA, trend, and volatility explanations

    Interactive charts and visualizations

    Hardware-accelerated local inference

    Native desktop performance

    Offline-capable architecture

    Windows, macOS, Linux, and ARM64 support

Platform Downloads

StockD provides platform-specific installers optimized for each hardware environment.

    ⚠️ Important Note on Large Files (macOS & NVIDIA Linux) > Due to the massive size of the bundled AI models and CUDA libraries (up to 5.7 GB), GitHub requires these specific installers to be split into multiple parts (.part_aa, .part_ab, etc.).

Download all split parts into the same folder and reconstruct them before running the installer.
Windows (x64)
Universal Installer

Compiled to run universally across all modern 64-bit Windows environments.
StockD-windows-x64-setup.exe

    Windows SmartScreen Notice: Because StockD bundles a complete local AI runtime, Windows may display: Windows protected your PC. Select More info → Run anyway.

macOS
Apple Silicon (ARM64)
Bash

cd ~/Downloads
cat StockD-mac-arm.dmg.part_* > StockD-mac-arm.dmg

Intel Macs
Bash

cd ~/Downloads
cat StockD-mac-intel.dmg.part_* > StockD-mac-intel.dmg

Installation:

    Open the generated DMG.

    Drag StockD.app into /Applications.

If Gatekeeper blocks execution:

System Settings → Privacy & Security → Open Anyway
Linux
NVIDIA Systems
Bash

# Debian/Ubuntu
cat StockD-linux-x64-nvidia-1.2.0.deb.part_* > StockD-linux-x64-nvidia-1.2.0.deb

# Fedora/RHEL
cat StockD-linux-x64-nvidia-1.2.0.rpm.part_* > StockD-linux-x64-nvidia-1.2.0.rpm

AMD Systems
Plaintext

StockD-linux-x64-amd-1.2.0.deb
StockD-linux-x64-amd-1.2.0.rpm

Intel Systems
Plaintext

StockD-linux-x64-intel-1.2.0.deb
StockD-linux-x64-intel-1.2.0.rpm

ARM64 Systems
Plaintext

StockD-linux-arm64-1.2.0.deb
StockD-linux-arm64-1.2.0.rpm

Linux Installation
Debian / Ubuntu / Mint
Bash

sudo dpkg -i StockD-linux-*.deb
sudo apt-get install -f

Fedora / RHEL / CentOS
Bash

sudo rpm -i StockD-linux-*.rpm

Technology Stack
Layer	Technology	Implementation Details
UI Rendering	Flutter 3.x	Native canvas-rendered desktop UI
State Management	Riverpod	Reactive state architecture
Navigation	GoRouter	Declarative route management
Charts	fl_chart	High-performance financial charting
Animation	flutter_animate	Gamification and progression effects
AI Runtime	FastAPI + TensorFlow	Local AI sidecar engine
Data Source	Historical Datasets	Bundled S&P 500 educational datasets
Architecture
Plaintext

[ Flutter Desktop UI Application ]
               │  ▲
  Localhost    │  │  JSON Messages
  loopback API │  │  (HTTP / WebSockets)
               ▼  │
 [ SAGE AI Sidecar Engine ]
   (Python + TensorFlow)

Frontend

The Flutter frontend manages:

    Rendering

    Navigation

    Charts

    Progression systems

    XP and streak tracking

    Animations

    User interaction

SAGE AI Engine

The SAGE sidecar engine manages:

    Educational explanations

    Historical market analysis

    Technical indicator interpretation

    Machine learning inference

    Context-aware tutoring

Communication Layer

Flutter and SAGE communicate through localhost APIs using JSON messages.

Benefits include:

    Low latency

    Process isolation

    Hardware acceleration

    Fault containment

    Offline operation

    Cross-platform portability

Runtime Data Storage

Persistent runtime data is stored using native user-space locations:

    Windows: %APPDATA%\StockD\

    Linux: ~/.config/stockd/

    macOS: ~/Library/Application Support/StockD/

No administrator privileges are required.
Curriculum
World 1 — Market Basics

Concepts: Equity ownership, Order books, Exchanges, Market indices

Difficulty: Beginner
World 2 — Reading the Tape

Concepts: Candlesticks, Price action, Support and resistance, Trend analysis

Difficulty: Beginner
World 3 — Fundamentals

Concepts: Earnings reports, Valuation metrics, Income statements, Balance sheets, Financial analysis

Difficulty: Intermediate

Each world currently contains:

    5 Levels

    10 Questions per Level

    Dynamic AI explanations powered by SAGE

Additional worlds are planned.
SAGE Philosophy
SAGE Is

    A teacher

    A coach

    An explainer

    A learning companion

SAGE Is Not

    A financial advisor

    A stock recommendation engine

    A trading bot

    A prediction system

    An autonomous portfolio manager

SAGE exists solely to improve financial literacy.
Privacy & Local Processing

StockD follows a local-first privacy model.

    All machine learning models execute locally.

    User interactions remain on-device.

    No cloud AI APIs are required.

    No subscription services are required.

    Full functionality is available offline.

This architecture provides both privacy and low-latency educational experiences.
Legal Notice

StockD is provided solely for educational and research purposes.

    StockD does not provide financial advice.

    StockD does not provide investment recommendations.

    StockD does not generate actionable buy/sell signals.

    Historical market datasets are used exclusively for educational explanations.

    Users should consult licensed financial professionals before making investment decisions.

StockD is an educational learning platform—not a trading platform.
