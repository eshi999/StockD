# main.py — FastAPI server wrapping sage_bridge.py
import os
os.environ["PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION"] = "python"

import sage_bridge as sage
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel


app = FastAPI(title="StockD SAGE API", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
async def startup():
    loaded = sage.load_model()
    print(f"SAGE model loaded: {loaded}")


# ── Health ────────────────────────────────────────────────────────────────────
@app.get("/health")
def health():
    return {
        "status": "ok",
        "model_loaded": sage._model is not None,
    }


# ── Stock History ─────────────────────────────────────────────────────────────
@app.get("/history/{ticker}")
def history(ticker: str, timeframe: str = "1Y"):
    result = sage.get_stock_history(ticker.upper(), timeframe=timeframe)
    if "error" in result:
        raise HTTPException(status_code=404, detail=result["error"])
    return result


# ── Market Snapshot ───────────────────────────────────────────────────────────
@app.get("/market/snapshot")
def market_snapshot():
    return sage.get_market_snapshot()


# ── SAGE Explain ──────────────────────────────────────────────────────────────
class ExplainRequest(BaseModel):
    question_id: str
    concept: str
    prompt: str
    user_answer: str
    correct_answer: str
    chart_symbol: str | None = None


@app.post("/sage/explain")
def explain(req: ExplainRequest):
    result = sage.explain_question(
        question_id=req.question_id,
        concept=req.concept,
        prompt=req.prompt,
        user_answer=req.user_answer,
        correct_answer=req.correct_answer,
        chart_symbol=req.chart_symbol,
    )
    return result


# ── SAGE Chat ─────────────────────────────────────────────────────────────────
class ChatMessage(BaseModel):
    message: str
    history: list[dict] = []


@app.post("/sage/chat")
def chat(req: ChatMessage):
    response = sage.chat(
        message=req.message,
        history=req.history,
    )
    return {
        "response": response,
        "disclaimer": "Educational information only. Not financial advice.",
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        app,  # your FastAPI app
        host="0.0.0.0",
        port=8000,
        reload=False,  # must be False in PyInstaller; reload uses multiprocessing
    )
