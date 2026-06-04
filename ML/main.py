import os
import uvicorn
import sage_bridge as sage
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from contextlib import asynccontextmanager

os.environ["PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION"] = "python"

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("[SYSTEM] Booting StockD SAGE API Server...")
    loaded = sage.load_model()
    print(f"[SYSTEM] Predictive layer operational verification: {loaded}")
    yield
    print("[SYSTEM] Terminating API Server loop...")

app = FastAPI(title="StockD SAGE API", version="2.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health():
    return {"status": "ok", "model_loaded": sage._model is not None}

@app.get("/history/{ticker}")
def history(ticker: str, timeframe: str = "1Y"):
    result = sage.get_stock_history(ticker.upper(), timeframe=timeframe)
    if "error" in result: raise HTTPException(status_code=404, detail=result["error"])
    return result

@app.post("/sage/chat")
def chat(req: dict):
    return {"response": sage.chat(message=req["message"], history=req.get("history", [])), "disclaimer": "Not financial advice."}

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)