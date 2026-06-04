import sage_bridge
print("1 loaded module")
sage_bridge.load_model()
print("2 loaded model")
df = sage_bridge._load_ticker_csv('NVDA')
print("3 df shape", df.shape)
if df.empty or len(df) < 200:
    print("4 insufficient data")
else:
    print("5 data ok")
