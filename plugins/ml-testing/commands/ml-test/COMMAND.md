# /ml-test

Write and run data quality tests, model unit tests, behavioral tests, and performance regression gates.

## Trigger

`/ml-test [action] [options]`

## Actions

- `data` - Generate data quality tests for a dataset (schema, nulls, distributions)
- `model` - Generate model unit tests (transforms, predictions, output shapes)
- `behavior` - Generate behavioral tests (MFT, invariance, directional)
- `performance` - Generate performance regression tests for CI gates

## Examples

### data — Pandera schema validation

```python
# tests/test_data.py
import pytest
import pandas as pd
import pandera as pa
from pandera import Column, Check, DataFrameSchema

schema = DataFrameSchema({
    "user_id": Column(str, nullable=False),
    "age": Column(int, [Check.ge(18), Check.le(120)], nullable=True),
    "purchase_amount": Column(float, Check.ge(0), nullable=True),
    "label": Column(int, Check.isin([0, 1]), nullable=False),
})

def test_training_data_schema():
    df = pd.read_parquet("data/train.parquet")
    schema.validate(df)
    assert df['user_id'].duplicated().sum() == 0, "Duplicate user IDs in training data"
    assert df['label'].value_counts(normalize=True).min() >= 0.05, "Extreme class imbalance"

def test_no_train_test_leakage():
    train = pd.read_parquet("data/train.parquet")
    test = pd.read_parquet("data/test.parquet")
    overlap = set(train['user_id']) & set(test['user_id'])
    assert len(overlap) == 0, f"{len(overlap)} users appear in both train and test"
```

### model — Transform unit tests

```python
# tests/test_transforms.py
import pytest
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler
from src.features import compute_rolling_features, apply_preprocessing_pipeline

def test_rolling_features_no_lookahead():
    """Rolling features must not use future data."""
    df = pd.DataFrame({
        'user_id': ['u1'] * 10,
        'value': range(10),
        'date': pd.date_range('2024-01-01', periods=10)
    })
    result = compute_rolling_features(df, window=3)
    # At t=0, rolling mean should be NaN (no history)
    assert pd.isna(result.iloc[0]['value_roll_mean_3d']), "Rolling feature leaks future data at t=0"
    # At t=2, rolling mean uses only t=0,1,2
    expected_mean = np.mean([0, 1, 2])
    assert abs(result.iloc[2]['value_roll_mean_3d'] - expected_mean) < 1e-6

def test_preprocessing_pipeline_output_shape(test_data):
    X = test_data.drop('label', axis=1)
    pipeline = apply_preprocessing_pipeline(X)
    X_out = pipeline.transform(X)
    assert X_out.shape[0] == len(X), "Preprocessing changed number of samples"
    assert not np.any(np.isnan(X_out)), "Preprocessing produced NaN values"

def test_preprocessing_no_fit_on_test(test_data):
    """Test that pipeline fit state was set on train data, not test."""
    train = pd.read_parquet("data/train.parquet").drop('label', axis=1)
    test = test_data.drop('label', axis=1)
    pipeline = apply_preprocessing_pipeline(train)  # fit on train
    X_test = pipeline.transform(test)               # transform test
    # Values should be near-zero mean, unit variance for StandardScaler features
    numeric_cols = train.select_dtypes('number').columns
    means = X_test[:, :len(numeric_cols)].mean(axis=0)
    # Test mean will NOT be 0 (only train mean would be exactly 0)
    # But should be reasonable — this catches gross fitting errors
    assert np.all(np.abs(means) < 3), "Test transform means are extreme — possible fit-on-test"
```

### behavior — Invariance and MFT tests

```python
# tests/test_behavior.py
import pytest

class TestMinimumFunctionality:
    def test_model_predicts_positive_class(self, model, feature_fixtures):
        """Model must predict the positive class for at least some examples."""
        X = feature_fixtures['clear_positives']
        preds = model.predict(X)
        assert (preds == 1).any(), "Model never predicts positive class — degenerate"

    def test_model_not_constant(self, model, test_data):
        """Model must predict both classes."""
        X = test_data.drop('label', axis=1)
        preds = model.predict(X)
        assert len(set(preds)) > 1, "Model predicts only one class — degenerate"

class TestInvariance:
    @pytest.mark.parametrize("feature,value", [
        ("user_gender", 0),
        ("user_gender", 1),
    ])
    def test_gender_invariant(self, model, base_features, feature, value):
        """Predictions should not differ based on gender feature alone."""
        X_male = base_features.copy()
        X_female = base_features.copy()
        X_male['user_gender'] = 0
        X_female['user_gender'] = 1
        pred_male = model.predict_proba(X_male)[:, 1]
        pred_female = model.predict_proba(X_female)[:, 1]
        max_diff = abs(pred_male - pred_female).max()
        assert max_diff < 0.05, (
            f"Max prediction diff by gender: {max_diff:.4f}. Possible bias."
        )
```

### performance — CI regression gate

```python
# tests/test_performance_regression.py
import pytest
import json
import numpy as np
from sklearn.metrics import f1_score

BASELINE_F1 = 0.847   # locked at last release
TOLERANCE = 0.01       # 1% allowed regression

def test_f1_regression(model, test_data):
    X = test_data.drop('label', axis=1)
    y = test_data['label']
    f1 = f1_score(y, model.predict(X), average='weighted')
    assert f1 >= BASELINE_F1 - TOLERANCE, (
        f"F1 regression: {f1:.4f} < {BASELINE_F1 - TOLERANCE:.4f} "
        f"(baseline={BASELINE_F1:.4f}, tolerance={TOLERANCE:.4f})"
    )
```

```bash
# Run all tests
pytest tests/ -v --tb=short

# Run only fast tests (exclude slow model loading)
pytest tests/ -v -m "not slow"

# Run with coverage
pytest tests/ --cov=src --cov-report=html --cov-fail-under=80

# CI command (fail on any test failure)
pytest tests/test_data.py tests/test_transforms.py tests/test_behavior.py \
  tests/test_performance_regression.py -v --tb=short --no-header \
  -q && echo "All ML tests passed"
```

## Options

- `--data-path <path>` - Path to dataset for data quality tests
- `--model-path <path>` - Path to model artifact for unit and behavioral tests
- `--baseline-file <path>` - Baseline metrics JSON for regression tests
- `--tolerance <float>` - Allowed metric regression (default: 0.01)
- `-m <markers>` - Pytest markers: slow, fast, behavioral, data, performance
