# /model-registry

Register, promote, compare, and retire ML models with full lineage, governance gates, and model cards.

## Trigger

`/model-registry [action] [options]`

## Actions

- `register` - Log model artifact to registry with signature and metadata
- `promote` - Evaluate and transition model through staging gates to Production
- `compare` - Champion vs challenger metric comparison with CI
- `retire` - Archive deprecated model versions with deprecation notes

## Examples

### register — Log model to MLflow Registry

```python
import mlflow
import mlflow.sklearn
from mlflow.models import infer_signature

mlflow.set_tracking_uri("http://mlflow-server:5000")

with mlflow.start_run(run_name="churn-lgbm-v2.3.0") as run:
    model.fit(X_train, y_train)
    y_proba = model.predict_proba(X_val)[:, 1]

    mlflow.log_metrics({
        "val_auc_roc": roc_auc_score(y_val, y_proba),
        "val_f1": f1_score(y_val, (y_proba > 0.5).astype(int)),
        "val_mcc": matthews_corrcoef(y_val, (y_proba > 0.5).astype(int)),
    })
    mlflow.log_params({
        "dataset_uri": "s3://ml-data/processed/v20240315/train.parquet",
        "dataset_sha256": "abc123def456",
        "git_commit": "d4e5f6a7",
    })

    signature = infer_signature(X_val, y_proba)
    mlflow.sklearn.log_model(
        model, artifact_path="model",
        signature=signature,
        registered_model_name="churn-model",
    )
```

### promote — Evaluate Staging model and promote to Production

```python
from mlflow.tracking import MlflowClient
import mlflow.pyfunc

client = MlflowClient()
MODEL_NAME = "churn-model"

# Load and evaluate staging candidate
staging = client.get_latest_versions(MODEL_NAME, stages=["Staging"])[0]
model = mlflow.pyfunc.load_model(f"models:/{MODEL_NAME}/{staging.version}")

y_proba = model.predict(X_holdout)
auc = roc_auc_score(y_holdout, y_proba)
f1 = f1_score(y_holdout, (y_proba > 0.5).astype(int))

print(f"Candidate v{staging.version}: AUC={auc:.4f}, F1={f1:.4f}")

if auc >= 0.82 and f1 >= 0.70:
    client.transition_model_version_stage(
        MODEL_NAME, staging.version, "Production",
        archive_existing_versions=True,
    )
    client.set_registered_model_alias(MODEL_NAME, "champion", staging.version)
    print(f"Promoted v{staging.version} to Production")
else:
    client.transition_model_version_stage(MODEL_NAME, staging.version, "Archived")
    print("Gate failed — archived candidate")
```

### compare — Champion vs challenger with bootstrap CI

```python
import numpy as np
from mlflow.tracking import MlflowClient
import mlflow.pyfunc

client = MlflowClient()
MODEL_NAME = "fraud-detector"

champion = mlflow.pyfunc.load_model(f"models:/{MODEL_NAME}@champion")
challenger = mlflow.pyfunc.load_model(f"models:/{MODEL_NAME}@challenger")

champ_proba = champion.predict(X_holdout)
chall_proba = challenger.predict(X_holdout)

# Bootstrap comparison
rng = np.random.default_rng(42)
diffs = []
for _ in range(2000):
    idx = rng.integers(0, len(y_holdout), len(y_holdout))
    if len(np.unique(y_holdout[idx])) < 2:
        continue
    auc_champ = roc_auc_score(y_holdout[idx], champ_proba[idx])
    auc_chall = roc_auc_score(y_holdout[idx], chall_proba[idx])
    diffs.append(auc_chall - auc_champ)

mean_diff = np.mean(diffs)
ci_low, ci_high = np.percentile(diffs, [2.5, 97.5])
significant = ci_low > 0

print(f"Champion AUC: {roc_auc_score(y_holdout, champ_proba):.4f}")
print(f"Challenger AUC: {roc_auc_score(y_holdout, chall_proba):.4f}")
print(f"Improvement: {mean_diff:+.4f} 95% CI [{ci_low:.4f}, {ci_high:.4f}]")
print(f"Significant: {significant}")
```

### retire — Archive with deprecation note

```python
from mlflow.tracking import MlflowClient

client = MlflowClient()

def retire_model_version(model_name: str, version: str, reason: str):
    """Archive model version with documented deprecation reason."""
    client.update_model_version(
        name=model_name,
        version=version,
        description=f"DEPRECATED: {reason}. Archived on 2024-03-15.",
    )
    client.transition_model_version_stage(model_name, version, "Archived")
    print(f"Archived {model_name} v{version}")

retire_model_version(
    "churn-model", "8",
    reason="Superseded by v9 with improved calibration; AUC delta +0.012"
)
```

## Options

- `--model-name <name>` - Registry model name
- `--version <n>` - Specific version number to operate on
- `--stage <stage>` - Target stage: Staging, Production, Archived
- `--auc-threshold <float>` - Minimum AUC for promotion gate (default: 0.80)
- `--f1-threshold <float>` - Minimum F1 for promotion gate (default: 0.65)
- `--n-bootstrap <n>` - Bootstrap iterations for CI comparison (default: 2000)
- `--alias <name>` - Semantic alias to assign on promotion (e.g., champion)
