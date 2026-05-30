# artifacts.py

import os
import json
import joblib

def ensure_dir(path: str) -> None:
    if path:
        os.makedirs(path, exist_ok=True)

def save_pickle(obj, path: str) -> None:
    ensure_dir(os.path.dirname(path))
    joblib.dump(obj, path)

def load_pickle(path: str):
    return joblib.load(path)

def save_json(obj, path: str) -> None:
    ensure_dir(os.path.dirname(path))
    with open(path, "w") as f:
        json.dump(obj, f, indent=2)

def load_json(path: str):
    with open(path, "r") as f:
        return json.load(f)
