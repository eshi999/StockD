try:
    import sage_bridge
    if not sage_bridge._model:
        sage_bridge.load_model()
    print("NVDA:", sage_bridge.predict_ticker('NVDA'))
except Exception as e:
    import traceback
    traceback.print_exc()
