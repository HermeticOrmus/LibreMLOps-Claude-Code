# ml-testing

Pytest patterns, data quality tests (Great Expectations, Pandera), behavioral testing (CheckList), and performance regression CI gates.

## What This Plugin Does

Covers the ML testing pyramid: data quality tests (schema, nulls, distributions, leakage checks), model unit tests (transform correctness, output shapes), behavioral tests (MFT, invariance, directional expectation), and performance regression gates that fail CI when model quality drops. Uses pytest, Pandera, Great Expectations, Deepchecks, and Evidently.

## When to Use

- Setting up a test suite for an ML project from scratch
- Writing pytest fixtures for model and data loading (load-once patterns)
- Creating data schema and distribution tests with Pandera or Great Expectations
- Implementing behavioral tests (invariance tests for fairness, MFT for capability)
- Building CI performance regression gates (fail if F1 drops > 1%)
- Testing preprocessing pipelines for leakage and correctness
- Diagnosing why existing tests don't catch real failures

## Components

| Component | Description |
|-----------|-------------|
| `agents/ml-test-engineer` | Expert in pytest for ML, Great Expectations, Deepchecks, Evidently, behavioral testing |
| `skills/ml-testing-patterns` | Code patterns: conftest fixtures, data quality, behavioral MFT/INV/DIR, performance gates |
| `commands/ml-test` | `/ml-test data\|model\|behavior\|performance` workflows |

## Key Concepts

**CheckList Behavioral Testing**
Three test types (Ribeiro et al. 2020): Minimum Functionality Tests (must work on obvious cases), Invariance Tests (output must not change for irrelevant input changes), Directional Expectations (output must change in the expected direction). These catch model biases and capability gaps invisible to accuracy metrics.

**Performance Regression Gate**
Lock baseline metrics at release time. CI test asserts `current_metric >= baseline - tolerance`. Hard failure blocks deployment. This prevents silent accuracy degradation during refactoring or data updates.

**session-scoped pytest Fixtures**
`@pytest.fixture(scope="session")` loads models once per test run. Without this, a test suite with 50 tests that each load a 500MB model takes 50× the time. Always scope ML fixtures to session or module.

**Data Leakage Tests**
Two critical tests: (1) No entity overlap between train and test splits. (2) No feature computed with future information relative to the label timestamp. Run both before every model training.

## Quick Start

```bash
pip install pytest pandera great_expectations deepchecks evidently
```

```python
# conftest.py
import pytest, joblib, pandas as pd

@pytest.fixture(scope="session")
def model(): return joblib.load("models/model.pkl")

@pytest.fixture(scope="session")
def test_data(): return pd.read_parquet("data/test.parquet")
```
