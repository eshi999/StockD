# tf_utils.py

import tensorflow as tf

def configure_tensorflow():
    try:
        gpus = tf.config.list_physical_devices("GPU")
        if gpus:
            for gpu in gpus:
                tf.config.experimental.set_memory_growth(gpu, True)
            print("GPU detected:", gpus)
            # Mixed precision can help on modern GPUs; keep it OFF until stable.
            # Uncomment if you want:
            # from tensorflow.keras import mixed_precision
            # mixed_precision.set_global_policy("mixed_float16")
            tf.config.optimizer.set_jit(False)
        else:
            print("No GPU detected. Using CPU.")
            tf.config.optimizer.set_jit(False)
    except Exception as e:
        print("TF configuration error:", e)
