# calibrate.py

import numpy as np
from sklearn.linear_model import LogisticRegression
from artifacts import save_joblib
from ml_config import CALIBRATION_PATH

def calibrate_model(model, X_val, y_val):
    """
    Fit a probability calibrator mapping raw p_up -> calibrated p_up.
    """
    raw_p, _ = model.predict(X_val, verbose=0)
    raw_p = raw_p.reshape(-1, 1).astype("float32")

    y_val = np.asarray(y_val).astype(int)

    lr = LogisticRegression(max_iter=200)
    lr.fit(raw_p, y_val)

    save_joblib(lr, CALIBRATION_PATH)
    print("Calibration saved ->", CALIBRATION_PATH)
