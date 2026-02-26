# /track-experiment

Initialize, log, compare, and promote ML experiments using MLflow or W&B.

## Trigger

`/track-experiment [action] [options]`

## Actions

- `init` - Set up MLflow or W&B tracking for a new project
- `log` - Add tracking instrumentation to existing training code
- `compare` - Query and compare runs across experiments
- `promote` - Tag best run for model registry promotion

## Examples

### init — Set up MLflow server and experiment

```bash
# Start local MLflow tracking server with SQLite backend
pip install mlflow
mlflow server \
  --backend-store-uri sqlite:///mlflow.db \
  --default-artifact-root s3://my-bucket/mlflow-artifacts \
  --host 0.0.0.0 --port 5000

# Or start minimal local UI (artifacts stored locally)
mlflow ui --port 5000
```

```python
import mlflow

mlflow.set_tracking_uri("http://localhost:5000")
mlflow.set_experiment("my-classification-task")

# Verify setup
experiments = mlflow.search_experiments()
for exp in experiments:
    print(f"{exp.name} (id={exp.experiment_id})")
```

```bash
# W&B: no server needed, init project
pip install wandb
wandb login
python -c "import wandb; wandb.init(project='my-project', name='setup-test')"
```

### log — Instrument existing training code

```python
# MLflow instrumentation
import mlflow

mlflow.set_experiment("bert-fine-tuning")

with mlflow.start_run(run_name="bert-base-lr3e4") as run:
    # Params: log once, at start
    mlflow.log_params({
        "model": "bert-base-uncased",
        "lr": 3e-4,
        "batch_size": 32,
        "epochs": 10,
    })

    for epoch in range(10):
        # Metrics: log per step
        mlflow.log_metrics({
            "train_loss": train_loss,
            "val_f1": val_f1,
        }, step=epoch)

    # Artifacts: log at end
    mlflow.log_artifact("outputs/confusion_matrix.png")
    mlflow.pytorch.log_model(model, "model",
                              registered_model_name="bert-sentiment")
```

```python
# W&B instrumentation (drop-in alongside existing code)
import wandb

wandb.init(
    project="bert-fine-tuning",
    name="bert-base-lr3e4",
    config={
        "model": "bert-base-uncased",
        "lr": 3e-4,
        "batch_size": 32,
        "epochs": 10,
    }
)

for epoch in range(10):
    wandb.log({"train_loss": train_loss, "val_f1": val_f1}, step=epoch)

wandb.save("outputs/confusion_matrix.png")
wandb.finish()
```

### compare — Query best runs

```python
import mlflow
import pandas as pd

# Find top runs by validation F1
runs = mlflow.search_runs(
    experiment_names=["bert-fine-tuning"],
    filter_string="metrics.val_f1 > 0.85 AND tags.status != 'exploration'",
    order_by=["metrics.val_f1 DESC"],
    max_results=10
)

comparison_cols = [
    "run_id", "run_name",
    "params.model", "params.lr", "params.batch_size",
    "metrics.val_f1", "metrics.val_loss",
    "tags.status", "start_time"
]
print(runs[comparison_cols].to_string(index=False))

# Find Pareto frontier: best F1 vs shortest training time
runs["val_f1"] = pd.to_numeric(runs["metrics.val_f1"])
runs["duration_min"] = (runs["end_time"] - runs["start_time"]).dt.total_seconds() / 60
pareto = runs[runs["val_f1"] > runs["val_f1"].quantile(0.8)]
print(pareto[["run_name", "val_f1", "duration_min"]].sort_values("val_f1", ascending=False))
```

### promote — Tag run for registry

```python
import mlflow
from mlflow.tracking import MlflowClient

client = MlflowClient()

# Tag the best run as production candidate
run_id = "adf3b2c1e4f5..."  # from comparison step

client.set_tag(run_id, "status", "production-candidate")
client.set_tag(run_id, "promoted_by", "ormus")
client.set_tag(run_id, "promotion_rationale", "Best val_f1 with smallest model, +2.3pp over baseline")

# Transition model version to Staging in registry
model_name = "bert-sentiment"
latest_versions = client.get_latest_versions(model_name, stages=["None"])
for mv in latest_versions:
    if mv.run_id == run_id:
        client.transition_model_version_stage(
            name=model_name,
            version=mv.version,
            stage="Staging",
            archive_existing_versions=False
        )
        print(f"Promoted {model_name} v{mv.version} to Staging")
```

## Options

- `--tracking-uri <uri>` - MLflow tracking server URI
- `--experiment <name>` - Experiment name to operate on
- `--run-id <id>` - Specific run ID to query or promote
- `--filter <query>` - MLflow search filter string
- `--top-n <n>` - Number of top runs to return in comparison
- `--backend <mlflow|wandb>` - Tracking backend (default: mlflow)
