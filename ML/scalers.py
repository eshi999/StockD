# scalers.py

class IdentityScaler:
    """No-op scaler for already-scaled features."""
    def fit(self, X): return self
    def transform(self, X): return X
    def fit_transform(self, X): return X
