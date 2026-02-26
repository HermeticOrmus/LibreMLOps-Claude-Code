# experiment-tracking

ML experiment organization, hyperparameter logging, and search with MLflow, W&B, Neptune, and Optuna.

## What This Plugin Does

Covers the discipline of making ML experiments reproducible and comparable: experiment/run/artifact hierarchy in MLflow, autologging vs manual logging tradeoffs, W&B sweeps for Bayesian hyperparameter search, Optuna integration, experiment comparison queries, and team tagging strategy for large-scale experiment management.

## When to Use

- Setting up MLflow or W&B for a new ML project
- Instrumenting existing training code with tracking
- Designing hyperparameter search with Optuna or W&B Sweeps
- Comparing runs to find what actually improved metrics
- Establishing team tagging conventions for experiment governance
- Promoting best experiments to the model registry

## Components

| Component | Description |
|-----------|-------------|
| `agents/experiment-tracker` | Expert in MLflow, W&B, Neptune, ClearML, Optuna, Ray Tune |
| `skills/experiment-tracking-patterns` | Code patterns: MLflow logging, W&B sweeps, Optuna+MLflow, run querying, tagging |
| `commands/track-experiment` | `/track-experiment init\|log\|compare\|promote` workflows |

## Key Concepts

**MLflow Hierarchy**
Experiments → Runs → {params, metrics, artifacts, tags}. Experiments are task-level buckets. Runs are individual training jobs. Params are immutable (hyperparams). Metrics support time series (step-level). Artifacts are files/models. Tags are free-form metadata for filtering.

**Autologging vs Manual**
`mlflow.sklearn.autolog()` captures params, metrics, and model automatically. Use it for standard frameworks. For custom training loops, log manually for precise control over what gets logged and when.

**W&B Sweeps**
Define search space and objective in YAML. Run Bayesian, grid, or random search across multiple agents. ASHA scheduler prunes bad trials early. Best suited for hyperparameter sensitivity analysis over broad ranges.

**Experiment Reproducibility**
An experiment is only reproducible if you log: (1) all params, (2) dataset version, (3) Git commit, (4) random seed, (5) model artifact with signature. Missing any one makes reproduction impossible.

## Quick Start

```bash
pip install mlflow optuna wandb
mlflow ui --port 5000  # local tracking UI
```

```python
import mlflow
mlflow.set_experiment("my-task")
with mlflow.start_run(run_name="baseline"):
    mlflow.log_params({"lr": 3e-4, "epochs": 10})
    mlflow.log_metric("val_f1", 0.847, step=10)
```
