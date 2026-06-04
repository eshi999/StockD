# ml_config.py

WINDOW_SIZE = 30          # days in the model input window
HORIZON_DAYS = 5          # days ahead for Target/FutureReturn (if computed)

# Columns present in YOUR dataset
FEATURE_COLS = [
    "Open", "High", "Low", "Close", "Volume",
    "SMA_50", "SMA_200", "RSI_14", "Daily_Return", "Volatility_20"
]

ARTIFACT_DIR = "artifacts"

# --- UPDATED PATHS FOR PLATFORM-AGNOSTIC SERIALIZATION ---
MODEL_ARCH_PATH = f"{ARTIFACT_DIR}/sage_model_arch.json"
MODEL_WEIGHTS_PATH = f"{ARTIFACT_DIR}/sage_model_weights.weights.h5"
SCALER_PATH = f"{ARTIFACT_DIR}/feature_scaler.joblib"
CALIBRATION_PATH = f"{ARTIFACT_DIR}/calibration.joblib"

METADATA_PATH = f"{ARTIFACT_DIR}/metadata.json"
END_USER_METRICS_PATH = f"{ARTIFACT_DIR}/end_user_metrics.json"
LESSON_DATASET_PATH = f"{ARTIFACT_DIR}/lesson_dataset.jsonl"
LESSON_SCHEMA_PATH = f"{ARTIFACT_DIR}/lesson_schema.json"

# Training controls
MAX_EPOCHS = 100
BATCH_SIZE = 64
EARLY_STOP_PATIENCE = 8
REDUCE_LR_PATIENCE = 4
MIN_LR = 1e-6

# Confidence bands (end-user behavior)
HIGH_CONF_BUY = 0.5401
HIGH_CONF_AVOID = 0.5114
