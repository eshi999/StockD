# StockD — Gamified Stock Market Literacy (Qt/QML + “Sage” Coach)

StockD is a desktop-first (and Qt-friendly) stock market literacy game. It’s **not** day trading, **not** meme stock hype, and **not** “blind AI predictions.”  
It’s a guided, gamified learning path where an in-app coach (“Sage”) explains market concepts and helps users anchor lessons to real tickers—without making decisions for them.

## What this repo contains

- **Qt/QML UI** for the game screens (Learn, Home, Portfolio, Stock Detail, etc.)
- A **Sage coaching layer** that plugs into screens to provide:
  - an ambient “coach panel” (always there, low effort)
  - a moment-based explanation panel (pre + post question)
  - optional live ticker context (price/RSI/signal/confidence depending on what you’ve implemented)
- The beginnings of an ML + data pipeline (kept lightweight in Git — see “Data & Git rules”)

> The core idea is **education + discipline + gamification**, not “AI that trades for you.”

---

## Tech stack

- **Qt 6 (Qt Creator)**
- **QML / QtQuick / QtQuick.Controls**
- C++ glue where needed (Sage client/controller/engine headers & sources)
- Optional Python/ML tooling in the `ML/` area (datasets are not committed)

---

## Project structure

StockD/
├─ CMakeLists.txt
├─ appStockD/ # C++ app target
│ ├─ main.cpp
│ ├─ SageClient.* # network/bridge (if used)
│ ├─ SageController.* # orchestration (if used)
│ ├─ SageEngine.* # logic layer (if used)
│ └─ ...
├─ qml/
│ ├─ Main.qml # app shell / navigation
│ ├─ HomeScreen.qml
│ ├─ LearnScreen.qml
│ ├─ PortfolioScreen.qml
│ ├─ StockDetailScreen.qml
│ ├─ ProfileScreen.qml
│ ├─ GameState.qml # XP, unlocks, lesson completion, etc.
│ ├─ SageStore.qml # Sage state (headline, bullets, active ticker, results)
│ └─ components/
│ ├─ SageCoachPanel.qml # reusable Sage UI
│ ├─ XPBar.qml
│ ├─ StockCard.qml
│ ├─ PrimaryButton.qml
│ └─ ...
├─ ML/
│ ├─ (scripts, models, notes)
│ └─ (datasets NOT committed)
└─ build/ # NOT committed (local only)


---

## How the game works (user flow)

1. **Home** shows your overview (XP, streak, progress, etc.)
2. **Learn** is the main “world map” of lessons (Duolingo-style path)
3. Each lesson opens a **question screen**:
   - user answers a multiple choice question
   - gets immediate feedback + explanation + fun fact
   - Sage can show context (ambient + moment-based)
4. Completing lessons grants **XP** and unlocks the next nodes

---

## Sage (coach) philosophy

Sage is not an “autopilot.” It’s a coach.

- It can explain *why* a concept matters
- It can connect a lesson to a ticker (ex: “momentum” anchored to NVDA)
- It can surface simple signals or indicators **as educational context**
- It should never say “buy this” as financial advice, or pretend it’s certain

Design rule we use:  
**“Sage explains. The user decides.”**

---

## Local setup

### Prereqs
- Qt 6.x installed (Qt Creator recommended)
- A working CMake toolchain (Qt Creator handles this fine)

### Build & run (Qt Creator)
1. Open the repo folder in Qt Creator
2. Configure kit (Desktop kit for your OS)
3. Build
4. Run

### Build folder rule
Keep builds out of version control.  
`build/` is local-only and ignored.

---

## Data & Git rules (important)

GitHub rejects files > 100MB. Our training dataset is large, so:

- **Do not commit raw datasets** (CSV, huge JSON, etc.)
- **Do not commit build output** (`build/`)

We keep the repo clean and reproducible:
- Scripts in `ML/` can download/generate data locally
- Models/artifacts can be generated locally (and optionally stored elsewhere)

### .gitignore basics
We ignore:
- `build/`
- large datasets (ex: `ML/sage_training_data.csv`)
- platform junk (ex: `.DS_Store`)

---

## Our workflow & process (how we build)

This project is being developed like a product, not a school demo. The workflow is:

### 1) UI-first prototype
- Build screens in QML with reusable components
- Keep animations lightweight and easy to tune (no overwhelming motion)
- Focus on clarity: “game feel” without visual chaos

### 2) Define game state + progression
- Lessons live in a simple data structure (title/xp/question/answers/explanation/fun fact)
- `GameState` tracks:
  - completed lessons
  - unlocked lessons
  - total XP
  - streak (optional)

### 3) Integrate Sage as a reusable component
- `SageCoachPanel` is dropped into screens like a widget
- `SageStore` holds state so multiple screens can read consistent Sage info
- We keep Sage “always present” but not intrusive:
  - ambient mode on the world map
  - moment mode on lesson screens

### 4) “Real stock anchoring”
- Each lesson can include `sageCtx` (ticker) and `sagePr` (prompt/intent tag)
- When a lesson is focused/started, we trigger events like:
  - `AppEvents.lessonNodeFocused(...)`
  - `AppEvents.lessonStarted(...)`
- Sage can then fetch or compute context for that ticker

### 5) Keep the repo shippable
- No build artifacts committed
- No giant datasets committed
- Everything needed to run the app is in source

---

## Conventions we follow

- QML components live in `qml/components/`
- Screens live in `qml/`
- If a screen uses components, it includes:
  ```qml
  import "components"
