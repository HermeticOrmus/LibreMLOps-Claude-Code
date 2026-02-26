# mlflow-integration

MLflow tracking server setup, model registry with stage transitions, MLproject files, custom Python function flavors, and model serving.

## What This Plugin Does

Covers the full MLflow operational stack: production server setup (PostgreSQL + S3), model signature and input example logging, registry stage transitions with evaluation gates, model aliases, MLproject for reproducible pipeline execution, custom pyfunc flavor for non-standard models, webhook automation for CI/CD triggers, and deployment to REST endpoints, Docker, and SageMaker.

## When to Use

- Setting up a team MLflow server with PostgreSQL backend and S3 artifact store
- Logging model signatures and input examples for serving-time schema validation
- Registering models to the MLflow Registry and managing stage transitions
- Defining MLproject files for reproducible training pipelines
- Registering ensemble or custom models via the pyfunc flavor
- Automating deployment CI/CD with MLflow registry webhooks
- Serving registered models as Docker containers or SageMaker endpoints

## Components

| Component | Description |
|-----------|-------------|
| `agents/mlflow-engineer` | Expert in MLflow server, registry, MLproject, serving, SageMaker/AzureML deployment |
| `skills/mlflow-patterns` | Code patterns: server setup, signatures, registry, MLproject, pyfunc, webhooks |
| `commands/mlflow` | `/mlflow track\|register\|serve\|promote` workflows |

## Key Concepts

**Backend Store vs Artifact Store**
Backend store (PostgreSQL): run metadata, params, metrics, tags. Fast, queryable. Artifact store (S3): large files (models, plots, datasets). Cheap, durable. Never mix them.

**Model Signature**
Documents input schema and output schema. `infer_signature(X_train, model.predict(X_train))`. Validated at serving time. Without it, schema mismatches cause silent wrong predictions.

**Registry Stages vs Aliases**
Stages (Staging/Production/Archived) are built-in but limited. Named aliases (`champion`, `challenger`) are flexible and support gradual rollout patterns. Prefer aliases for new deployments.

**Custom pyfunc Flavor**
Implement `PythonModel` to register any Python object as an MLflow model. This is how you register sklearn pipelines with custom preprocessing, ensemble models, or models with external artifacts.

## Quick Start

```bash
pip install mlflow psycopg2-binary boto3
mlflow server \
  --backend-store-uri sqlite:///mlflow.db \
  --default-artifact-root ./mlruns \
  --port 5000
```

```python
import mlflow
mlflow.set_tracking_uri("http://localhost:5000")
mlflow.set_experiment("my-experiment")
with mlflow.start_run(): mlflow.log_metric("val_f1", 0.89)
```
