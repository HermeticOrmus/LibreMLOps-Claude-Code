# feature-engineering

Feature stores (Feast, Tecton, Hopsworks), transformation pipelines, selection, time-series features, and drift monitoring.

## What This Plugin Does

Covers the full feature engineering lifecycle: designing feature views and entity schemas for Feast/Hopsworks, implementing sklearn Pipeline and ColumnTransformer for leakage-free transforms, computing time-series lag/rolling/cyclical features, selecting features with SHAP or RFECV, encoding high-cardinality categoricals, and monitoring feature drift with PSI and KS tests.

## When to Use

- Setting up a Feast feature store with offline and online stores
- Building sklearn ColumnTransformer pipelines that prevent leakage
- Computing lag, rolling, and expanding window features for time-series tasks
- Detecting and fixing training-serving skew (online vs offline feature parity)
- Selecting features using SHAP importance or RFE
- Implementing target encoding for high-cardinality categoricals without leakage
- Monitoring feature drift in production (PSI, KS test)

## Components

| Component | Description |
|-----------|-------------|
| `agents/feature-engineer` | Expert in Feast, Hopsworks, sklearn pipelines, SHAP selection, time-series features |
| `skills/feature-engineering-patterns` | Code patterns: Feast setup, ColumnTransformer, time-series, target encoding, SHAP selection, PSI |
| `commands/features` | `/features compute\|register\|retrieve\|validate` workflows |

## Key Concepts

**Point-in-Time Correctness**
When building training data, features must only use information available at the label timestamp. `feast.get_historical_features(entity_df)` performs this join automatically using `event_timestamp`. Manual join with `WHERE feature_ts <= label_ts` is the equivalent in SQL.

**Online vs Offline Feature Parity**
Training uses the offline store (Parquet/BigQuery). Serving uses the online store (Redis/DynamoDB). If the computation logic differs between the two, you have online/offline skew — the model sees different distributions than it was trained on. Test parity with KS test on a sample.

**sklearn Pipeline as Leakage Guard**
`Pipeline.fit(X_train)` fits all stages on training data only. `Pipeline.transform(X_test)` applies the fitted transform to test data without refitting. This is the correct pattern. Fitting a scaler on the full dataset before splitting is leakage.

**PSI for Drift**
PSI (Population Stability Index) quantifies how much a feature distribution has shifted from training. PSI > 0.25 triggers investigation. Monitor PSI on all serving features, not just the ones correlated with model performance.

## Quick Start

```bash
pip install feast scikit-learn polars shap scipy
feast init feature_repo && cd feature_repo
feast apply
```

```python
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
pipe = Pipeline([('scale', StandardScaler())])
pipe.fit(X_train)  # never fit on X_test
X_test_transformed = pipe.transform(X_test)
```
