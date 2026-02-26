# /features

Compute, register, retrieve, and validate ML features via feature stores and transformation pipelines.

## Trigger

`/features [action] [options]`

## Actions

- `compute` - Build feature transformation pipeline for a dataset
- `register` - Push feature definitions to Feast or Hopsworks feature store
- `retrieve` - Generate code to retrieve features for training or serving
- `validate` - Check for leakage, online/offline skew, and drift

## Examples

### compute — Build sklearn feature pipeline

```python
from sklearn.pipeline import Pipeline
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.impute import SimpleImputer

numeric_features = ['age', 'purchase_count_30d', 'days_since_signup']
categorical_features = ['country', 'device_type', 'subscription_tier']

preprocessor = ColumnTransformer([
    ('num', Pipeline([
        ('imputer', SimpleImputer(strategy='median')),
        ('scaler', StandardScaler()),
    ]), numeric_features),
    ('cat', Pipeline([
        ('imputer', SimpleImputer(strategy='most_frequent')),
        ('encoder', OneHotEncoder(drop='first', handle_unknown='ignore', sparse_output=False)),
    ]), categorical_features),
])

# Fit on train only
preprocessor.fit(X_train)
X_train_transformed = preprocessor.transform(X_train)
X_test_transformed = preprocessor.transform(X_test)

# Save
import joblib
joblib.dump(preprocessor, 'preprocessor_v1.joblib')
```

### register — Feast feature view

```python
from feast import FeatureStore, Entity, FeatureView, Field, FileSource
from feast.types import Float32, Int64
from datetime import timedelta

user = Entity(name="user_id")

user_features_fv = FeatureView(
    name="user_features_v2",
    entities=[user],
    ttl=timedelta(days=30),
    schema=[
        Field(name="purchase_count_30d", dtype=Float32),
        Field(name="total_spend_30d", dtype=Float32),
        Field(name="avg_order_value_30d", dtype=Float32),
        Field(name="days_since_last_purchase", dtype=Float32),
    ],
    online=True,
    source=FileSource(
        path="s3://features/user_features/",
        timestamp_field="event_timestamp",
    ),
)

# Apply to feature store
store = FeatureStore(repo_path="feature_repo/")
store.apply([user, user_features_fv])

# Materialize to online store (Redis)
from datetime import datetime
store.materialize(
    start_date=datetime(2024, 1, 1),
    end_date=datetime.utcnow()
)
```

### retrieve — Training data with point-in-time joins

```python
import pandas as pd
from feast import FeatureStore

store = FeatureStore(repo_path="feature_repo/")

# Entity dataframe: entity key + label timestamp (prevents leakage)
entity_df = pd.read_parquet("data/labels_with_timestamps.parquet")
# Required columns: user_id, event_timestamp, label

training_df = store.get_historical_features(
    entity_df=entity_df,
    features=[
        "user_features_v2:purchase_count_30d",
        "user_features_v2:total_spend_30d",
        "user_features_v2:avg_order_value_30d",
        "user_features_v2:days_since_last_purchase",
    ]
).to_df()

print(f"Training shape: {training_df.shape}")
print(training_df.describe())

# Online retrieval (serving)
online_features = store.get_online_features(
    features=["user_features_v2:purchase_count_30d"],
    entity_rows=[{"user_id": "user_123"}]
).to_dict()
```

### validate — Leakage and drift checks

```python
import pandas as pd
import numpy as np
from scipy.stats import ks_2samp

def check_temporal_leakage(df: pd.DataFrame, feature_cols: list,
                             label_col: str, timestamp_col: str) -> dict:
    """Check if any features have suspicious correlation with future labels."""
    issues = {}
    for col in feature_cols:
        # Feature should not have higher correlation with future labels than current
        corr_current = df[col].corr(df[label_col])
        corr_future = df[col].corr(df[label_col].shift(-1))
        if abs(corr_future) > abs(corr_current) + 0.05:
            issues[col] = {
                "current_corr": round(corr_current, 4),
                "future_corr": round(corr_future, 4),
                "warning": "Feature may have temporal leakage"
            }
    return issues

def check_online_offline_skew(offline_features: pd.DataFrame,
                               online_features: pd.DataFrame,
                               feature_cols: list) -> pd.DataFrame:
    """Compare distributions of offline vs online feature values."""
    records = []
    for col in feature_cols:
        stat, p_value = ks_2samp(
            offline_features[col].dropna(),
            online_features[col].dropna()
        )
        records.append({
            "feature": col,
            "ks_stat": round(stat, 4),
            "p_value": round(p_value, 6),
            "skew_detected": p_value < 0.01
        })
    return pd.DataFrame(records).sort_values("ks_stat", ascending=False)

# PSI check
def psi(expected, actual, bins=10):
    ep = np.histogram(expected, bins=bins)[0] / len(expected) + 1e-6
    ap = np.histogram(actual, bins=bins, range=(expected.min(), expected.max()))[0] / len(actual) + 1e-6
    return float(np.sum((ap - ep) * np.log(ap / ep)))

for col in feature_cols:
    score = psi(train_df[col].dropna().values, prod_df[col].dropna().values)
    status = "OK" if score < 0.1 else "WARN" if score < 0.25 else "DRIFT"
    print(f"{col}: PSI={score:.4f} [{status}]")
```

## Options

- `--feature-store <feast|hopsworks|tecton>` - Target feature store
- `--repo-path <path>` - Feast feature repo directory
- `--entity-col <col>` - Entity column name (default: entity_id)
- `--timestamp-col <col>` - Event timestamp column for point-in-time joins
- `--online` - Include online store materialization in register
- `--drift-threshold <float>` - PSI threshold for drift alert (default: 0.25)
