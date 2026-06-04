import sage_bridge
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
sage_bridge.load_model()
for t in ["NVDA", "AAPL", "TSLA", "META", "AMD"]:
    try:
        res = sage_bridge.predict_ticker(t)
        print(t, "SUCCESS", dict(res))
    except Exception as e:
        print(t, "ERROR", e)
