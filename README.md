# StockD — Gamified Stock Market Literacy

StockD is a desktop-first stock market literacy app built with Flutter. It's **not** day trading, **not** meme stock hype, and **not** "blind AI predictions."  
It's a guided, gamified learning path where an in-app AI coach ("SAGE") explains market concepts and anchors lessons to real S&P 500 data — without making decisions for users.

> **"SAGE explains. The user decides."**

---

## What this repo contains

- **Flutter desktop UI** for Linux/macOS/Windows
- **SAGE AI coaching layer** powered by a local ML backend:
  - Explains wrong answers using real S&P 500 data + charts
  - Educational chatbot for stock market concepts
  - Never gives buy/sell advice
- **Python ML backend** (FastAPI + TensorFlow) in `ML/`
- **Duolingo-style progression** — Worlds → Levels → 20 Questions each

---

## Tech stack

| Layer | Technology |
|---|---|
| UI | Flutter 3.x (Dart) |
| State | Riverpod 3.x |
| Navigation | GoRouter 17.x |
| Charts | fl_chart |
| Animations | flutter_animate |
| ML Backend | FastAPI + TensorFlow 2.21 |
| Data | yfinance + local S&P 500 CSVs |

---

## Project structure
```
StockD/
├─ lib/
│  ├─ main.dart                  # App entry point + router
│  ├─ theme/app_theme.dart        # Colors, typography, theme
│  ├─ models/
│  │  ├─ models.dart              # World, Level, Question, Progress
│  │  └─ curriculum.dart          # All worlds, levels, questions
│  ├─ providers/
│  │  ├─ progress_provider.dart   # XP, streak, hearts
│  │  ├─ lesson_provider.dart     # Active lesson state
│  │  └─ sage_provider.dart       # Backend status + SAGE explanations
│  ├─ services/
│  │  ├─ sage_service.dart        # HTTP client → ML backend
│  │  └─ storage_service.dart     # SharedPreferences persistence
│  ├─ screens/
│  │  ├─ overworld/               # World map (bg_overworld.png)
│  │  ├─ home/                    # Dashboard
│  │  ├─ world/                   # Level select
│  │  ├─ lesson/                  # Question + result screens
│  │  ├─ chat/                    # SAGE chatbot
│  │  └─ sage/                    # SAGE explanation screen
│  └─ widgets/
│     ├─ sidebar.dart             # Collapsible nav sidebar
│     ├─ dashboard.dart           # Home dashboard
│     ├─ stock_chart.dart         # Interactive price chart
│     ├─ question_card.dart       # Question + answer options
│     └─ sage_panel.dart          # SAGE explanation panel
├─ ML/
│  ├─ main.py                     # FastAPI server
│  ├─ sage_bridge.py              # ML bridge (chat, explain, history)
│  ├─ inference.py                # CLI inference tool
│  ├─ fetch_sp500.py              # S&P 500 data downloader
│  ├─ train_sage.py               # Model training
│  └─ artifacts/                  # Model files (not committed)
├─ assets/
│  └─ images/                     # World images + overworld background
└─ .gitignore
```

---

## How the app works

1. **Overworld map** — choose a world to study
2. **World screen** — pick a level (5 levels per world, 20 questions each)
3. **Lesson screen** — answer multiple choice questions
   - Correct → XP earned, next question
   - Wrong → SAGE explains using real S&P 500 data + chart
4. **Result screen** — stars + XP summary
5. **SAGE Chat** — ask any stock market question anytime

### Worlds
| World | Topic | Difficulty |
|---|---|---|
| 🌿 Market Basics | Stocks, exchanges, indices | Beginner |
| 🏘️ Reading the Tape | Charts, candlesticks, price action | Beginner |
| 🏙️ Fundamentals | Earnings, valuation, balance sheets | Intermediate |

---

## SAGE philosophy

SAGE is a coach, not an autopilot.

- Explains *why* a concept matters
- Connects lessons to real S&P 500 tickers and historical data
- Surfaces indicators (RSI, SMA, volatility) **as educational context**
- **Never gives buy/sell advice**
- Always shows: *"⚠️ Educational information only, not financial advice."*

---

## Local setup

### Prerequisites
- Flutter 3.x (`flutter doctor` should pass)
- Python 3.12
- Linux/macOS/Windows desktop

### Flutter app
```bash
flutter pub get
flutter run -d linux   # or macos / windows
```

The app automatically starts the ML backend on launch.

### ML backend (manual start)
```bash
cd ML
python3.12 -m pip install -r requirements.txt
python3.12 -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Fetch S&P 500 data
```bash
cd ML
python3.12 fetch_sp500.py
```

### Test the API
```bash
curl http://localhost:8000/health
curl -X POST http://localhost:8000/sage/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "What is RSI?", "history": []}'
```

---

## Data & Git rules

GitHub rejects files >100MB. Large data files are excluded:

- `ML/historical/` — S&P 500 CSVs (regenerate with `fetch_sp500.py`)
- `ML/artifacts/*.keras` — model weights (train with `train_sage.py`)
- `ML/sage_training_data.csv` — training dataset

Everything needed to reproduce the data pipeline is in source.

---

## Requirements
```
# ML/requirements.txt
fastapi
uvicorn[standard]
tensorflow==2.21.0
pandas
numpy
scikit-learn
yfinance
pydantic
```
