# build_lesson_dataset.py

import os
import json
import numpy as np
import pandas as pd

from ml_config import *
from artifacts import save_json
from sequence_utils import build_windows
from inference import predict

os.makedirs(ARTIFACT_DIR, exist_ok=True)

df = pd.read_csv("sage_training_data.csv")
df["Date"] = pd.to_datetime(df["Date"])
df = df.dropna(subset=FEATURE_COLS + ["Target", "FutureReturn"]).copy()
df.sort_values(["Ticker", "Date"], inplace=True)

X, y_class, y_ret, meta = build_windows(df)

schema = {
    "description": "Lesson-ready dataset: model outputs + ground truth + traceability. No lessons generated here.",
    "fields": {
        "ticker": "str",
        "end_date": "str",
        "p_up": "float",
        "expected_return": "float",
        "action": "BUY|HOLD|AVOID",
        "confidence": "HIGH|LOW",
        "actual_target": "int",
        "actual_future_return": "float",
        "correct": "int",
        "window_size": "int",
        "horizon_days": "int",
        "evidence": "dict of numeric evidence derived from last day in window"
    }
}
save_json(schema, LESSON_SCHEMA_PATH)

out_path = LESSON_DATASET_PATH
with open(out_path, "w") as f:
    for i in range(len(y_class)):
        out = predict(X[i])

        # Simple numeric evidence hooks (from last day of window)
        last = X[i][-1]
        evidence = {FEATURE_COLS[j]: float(last[j]) for j in range(len(FEATURE_COLS))}

        record = {
            "ticker": meta[i]["ticker"],
            "end_date": meta[i]["end_date"],
            "p_up": float(out["p_up"]),
            "expected_return": float(out["expected_return"]),
            "action": out["action"],
            "confidence": out["confidence"],
            "actual_target": int(y_class[i]),
            "actual_future_return": float(y_ret[i]),
            "correct": int(((out["p_up"] >= 0.5) == bool(y_class[i]))),
            "window_size": WINDOW_SIZE,
            "horizon_days": HORIZON_DAYS,
            "evidence": evidence,
        }
        f.write(json.dumps(record) + "\n")

print("Wrote lesson-ready dataset ->", out_path)
print("Wrote schema ->", LESSON_SCHEMA_PATH)
