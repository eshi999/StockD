# sequence_utils.py

import numpy as np
import pandas as pd
from ml_config import FEATURE_COLS, WINDOW_SIZE

def build_windows(df: pd.DataFrame):
    """
    Build rolling windows per ticker.

    Returns:
      X: (N, WINDOW_SIZE, num_features)
      y_class: (N,)
      y_ret: (N,)
      meta: list of dicts with ticker, end_date (for traceability)
    """
    X_list, y_c_list, y_r_list, meta = [], [], [], []

    for ticker, g in df.groupby("Ticker", sort=False):
        g = g.sort_values("Date").reset_index(drop=True)

        feats = g[FEATURE_COLS].astype("float32").values
        y_c = g["Target"].astype("int32").values
        y_r = g["FutureReturn"].astype("float32").values
        dates = g["Date"].astype(str).values

        if len(g) < WINDOW_SIZE:
            continue

        for end in range(WINDOW_SIZE - 1, len(g)):
            start = end - (WINDOW_SIZE - 1)
            X_list.append(feats[start:end+1])
            y_c_list.append(y_c[end])
            y_r_list.append(y_r[end])
            meta.append({"ticker": str(ticker), "end_date": str(dates[end])})

    X = np.asarray(X_list, dtype=np.float32)
    y_class = np.asarray(y_c_list, dtype=np.int32)
    y_ret = np.asarray(y_r_list, dtype=np.float32)
    return X, y_class, y_ret, meta
