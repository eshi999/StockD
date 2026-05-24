# train_sage.py

import os
import logging
import random
from pathlib import Path
import math

import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow.keras import layers, Model
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau, ModelCheckpoint, Callback

from ml_config import *
from sequence_utils import build_windows
from calibrate import calibrate_model


# -----------------------
# LOGGING SETUP
# -----------------------
os.environ["TF_CPP_MIN_LOG_LEVEL"] = "2"
logging.getLogger("tensorflow").setLevel(logging.ERROR)

print = lambda *args, **kwargs: __builtins__.print(*args, flush=True, **kwargs)

SEED = 42
random.seed(SEED)
np.random.seed(SEED)
tf.random.set_seed(SEED)


# -----------------------
# HARDWARE
# -----------------------
def setup_hardware():
    gpus = tf.config.list_physical_devices("GPU")
    if gpus:
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
        print("✔️ GPU detected:", gpus)
    else:
        print("⚠️ No GPU detected.")

setup_hardware()


# -----------------------
# MODEL
# -----------------------
def build_model(input_shape):

    inp = layers.Input(shape=input_shape)

    x = layers.LSTM(128, return_sequences=True, kernel_regularizer=tf.keras.regularizers.l2(1e-4))(inp)
    x = layers.Dropout(0.3)(x)
    x = layers.LSTM(64, kernel_regularizer=tf.keras.regularizers.l2(1e-4))(x)
    x = layers.Dropout(0.3)(x)
    x = layers.Dense(128, activation="relu", kernel_regularizer=tf.keras.regularizers.l2(1e-4))(x)

    p_up = layers.Dense(1, activation="sigmoid", name="p_up")(x)
    expected_return = layers.Dense(1, name="expected_return")(x)

    model = Model(inp, [p_up, expected_return])

    model.compile(
        optimizer=tf.keras.optimizers.Adam(1e-3),
        loss=[
            "binary_crossentropy",
            tf.keras.losses.Huber()
        ],
        loss_weights=[1.0, 0.1],   # 🔥 Classification dominant
        metrics=[
            [tf.keras.metrics.BinaryAccuracy(name="acc"),
             tf.keras.metrics.AUC(name="auc")],
            []
        ]
    )

    return model


# -----------------------
# MAIN
# -----------------------
if __name__ == "__main__":

    print("🚀 SAGE TRAINING STARTED")

    BASE_DIR = Path(__file__).parent.resolve()
    DATA_FILE = BASE_DIR / "sage_training_data.csv"

    df = pd.read_csv(DATA_FILE)
    df["Date"] = pd.to_datetime(df["Date"])
    df = df.dropna(subset=FEATURE_COLS + ["Target", "FutureReturn"])
    df.sort_values(["Ticker", "Date"], inplace=True)

    print("Rows:", len(df), "Tickers:", df["Ticker"].nunique())

    print("📦 Building rolling windows...")
    X, y_class, y_ret, meta = build_windows(df)

    print("Total windows:", len(X))

    # Cap for faster iteration
    MAX_WINDOWS = 300000
    if len(X) > MAX_WINDOWS:
        X = X[-MAX_WINDOWS:]
        y_class = y_class[-MAX_WINDOWS:]
        y_ret = y_ret[-MAX_WINDOWS:]
        meta = meta[-MAX_WINDOWS:]
        print("Using last", MAX_WINDOWS, "windows")

    # Train/Val split (last 20% time-based)
    split = int(0.8 * len(X))

    X_train, X_val = X[:split], X[split:]
    y_class_train, y_class_val = y_class[:split], y_class[split:]
    y_ret_train, y_ret_val = y_ret[:split], y_ret[split:]

    print("Train:", len(X_train), "| Val:", len(X_val))

    pos_rate = y_class_train.mean()
    print("Positive rate:", round(float(pos_rate), 4))

    model = build_model((WINDOW_SIZE, len(FEATURE_COLS)))

    os.makedirs(ARTIFACT_DIR, exist_ok=True)

    early = EarlyStopping(
        monitor="val_loss",
        patience=6,
        restore_best_weights=True,
        verbose=1
    )

    reduce = ReduceLROnPlateau(
        monitor="val_loss",
        factor=0.5,
        patience=3,
        verbose=1
    )

    checkpoint = ModelCheckpoint(
        BEST_MODEL_PATH,
        monitor="val_loss",
        save_best_only=True,
        verbose=1
    )

    print("🧠 Training...")

    history = model.fit(
        X_train,
        [y_class_train, y_ret_train],
        validation_data=(X_val, [y_class_val, y_ret_val]),
        epochs=100,
        batch_size=128,
        shuffle=True,
        callbacks=[early, reduce, checkpoint],
        verbose=1
    )

    model.save(MODEL_PATH)
    print("✅ Final model saved")

    print("🔬 Calibrating...")
    calibrate_model(model, X_val, y_class_val)

    print("🎉 Training complete.")
