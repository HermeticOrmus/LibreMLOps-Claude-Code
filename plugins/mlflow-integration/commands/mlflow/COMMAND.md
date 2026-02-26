# /mlflow

Set up MLflow infrastructure, track experiments, register models, and serve predictions.

## Trigger

`/mlflow [action] [options]`

## Actions

- `track` - Instrument training code with MLflow tracking
- `register` - Register a trained model to the MLflow Model Registry
- `serve` - Deploy a registered model as a REST endpoint
- `promote` - Transition a model version through registry stages

## Examples

### track — Basic experiment tracking

```python
import mlflow
import mlflow.pytorch

mlflow.set_tracking_uri("http://mlflow-server:5000")
mlflow.set_experiment("bert-sentiment")

with mlflow.start_run(run_name="bert-base-lr3e4-ep10"):
    # Log hyperparameters
    mlflow.log_params({
        "model": "bert-base-uncased",
        "lr": 3e-4,
        "batch_size": 32,
        "epochs": 10,
    })

    for epoch in range(10):
        train_loss, val_f1 = train_and_eval(epoch)
        mlflow.log_metrics({"train_loss": train_loss, "val_f1": val_f1}, step=epoch)

    # Log artifacts
    mlflow.log_artifact("confusion_matrix.png")

    # Log model with signature
    from mlflow.models import infer_signature
    signature = infer_signature(X_val_sample, model.predict(X_val_sample))
    mlflow.pytorch.log_model(model, "model", signature=signature,
                              registered_model_name="sentiment-bert")
```

### register — Register existing model from run

```python
from mlflow.tracking import MlflowClient
import mlflow

client = MlflowClient()

# Register from run artifact
run_id = "abc123def456"  # from mlflow UI or search_runs
model_uri = f"runs:/{run_id}/model"
model_version = mlflow.register_model(model_uri, "sentiment-bert")
print(f"Registered: {model_version.name} v{model_version.version}")

# Add description
client.update_model_version(
    name="sentiment-bert",
    version=model_version.version,
    description="BERT-base fine-tuned on Amazon reviews. val_f1=0.892. Dataset: amazon-v3."
)

# Add alias for flexible loading
client.set_registered_model_alias("sentiment-bert", "champion", model_version.version)

# Load by alias
loaded = mlflow.pyfunc.load_model("models:/sentiment-bert@champion")
```

### serve — Deploy as REST endpoint

```bash
# Serve locally
mlflow models serve \
  --model-uri "models:/sentiment-bert/Production" \
  --port 5001 \
  --no-conda

# Test endpoint
curl http://localhost:5001/invocations \
  -H "Content-Type: application/json" \
  -d '{"dataframe_split": {"columns": ["text"], "data": [["This product is excellent!"]]}}'

# Build Docker image
mlflow models build-docker \
  --model-uri "models:/sentiment-bert/Production" \
  --name sentiment-bert:latest

# Deploy to SageMaker
import mlflow.sagemaker
mlflow.sagemaker.deploy(
    app_name="sentiment-bert-prod",
    model_uri="models:/sentiment-bert/Production",
    region_name="us-east-1",
    mode="create",
    instance_type="ml.m5.xlarge",
    instance_count=2,
)
```

### promote — Stage transition with gate

```python
from mlflow.tracking import MlflowClient

client = MlflowClient()
model_name = "sentiment-bert"

def promote_to_staging(version: str, min_val_f1: float = 0.88):
    """Gate: only promote if evaluation metrics meet threshold."""
    mv = client.get_model_version(model_name, version)
    run = client.get_run(mv.run_id)
    val_f1 = run.data.metrics.get("val_f1", 0)

    if val_f1 < min_val_f1:
        print(f"BLOCKED: val_f1={val_f1:.4f} < threshold={min_val_f1}")
        return False

    client.transition_model_version_stage(
        name=model_name, version=version, stage="Staging",
        archive_existing_versions=False
    )
    client.set_tag(mv.run_id, "promoted_to_staging", "true")
    print(f"Promoted {model_name} v{version} to Staging (val_f1={val_f1:.4f})")
    return True

def promote_to_production(staging_version: str):
    """Archive current Production, promote Staging."""
    client.transition_model_version_stage(
        name=model_name, version=staging_version, stage="Production",
        archive_existing_versions=True  # archive existing Production versions
    )
    client.set_registered_model_alias(model_name, "champion", staging_version)
    print(f"Promoted {model_name} v{staging_version} to Production")

# Run gates
promote_to_staging("7")
promote_to_production("7")
```

## Options

- `--tracking-uri <uri>` - MLflow tracking server URI
- `--model-name <name>` - Registered model name
- `--version <n>` - Model version number
- `--stage <staging|production|archived>` - Target registry stage
- `--port <n>` - Port for model serving (default: 5001)
- `--min-metric <float>` - Minimum metric threshold for promotion gate
