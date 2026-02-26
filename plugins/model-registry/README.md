# model-registry

Model versioning, staging gates, champion/challenger promotion, model cards, and webhook-driven CI/CD with MLflow Registry, W&B Artifacts, and Hugging Face Hub.

## What This Plugin Does

Covers the full model governance lifecycle: registering model artifacts with inferred signatures and dataset lineage, transitioning through Staging → Production with automated evaluation gates, semantic aliases (champion/challenger) decoupled from numeric versions, model card generation per HuggingFace/Google standard, bootstrap CI comparison between champion and challenger, webhook-driven CI promotion pipelines, and safe retirement with audit trail preservation.

## When to Use

- Registering a trained model artifact with MLflow including metrics, dataset SHA, and git commit
- Setting up a staging gate that runs evaluation before promoting to Production
- Implementing champion/challenger shadow evaluation to compare model versions on live traffic
- Generating a structured model card with per-subgroup metrics and known limitations
- Building a webhook receiver that triggers CI evaluation when a model transitions to Staging
- Comparing champion vs challenger with bootstrap confidence intervals before promoting
- Retiring deprecated model versions with documented reasons (never deleting)

## Components

| Component | Description |
|-----------|-------------|
| `agents/registry-engineer` | Expert in MLflow Registry, W&B Artifacts, HF Hub, model cards, champion/challenger, webhooks |
| `skills/model-registry-patterns` | Registration with lineage, staging gates, alias-based promotion, model card generation, webhook CI |
| `commands/model-registry` | `/model-registry register\|promote\|compare\|retire` workflows |

## Key Concepts

**Semantic Aliases Over Version Numbers**
Hardcoding `models:/churn-model/15` in serving code breaks at every promotion. Use aliases: `models:/churn-model@champion`. Promotion becomes an alias reassignment, not a serving code change. MLflow 2.x aliases are the canonical approach.

**Model Cards Are Not Optional**
A model in Production without a model card has no documented intended use, known failures, or fairness evaluation. Any Production promotion must include a filled model card with evaluation metrics by subgroup. The Hugging Face model card format is a workable standard for any organization.

**Champion/Challenger Pattern**
Shadow mode: challenger receives all requests, outputs discarded, responses compared offline. Canary mode: challenger receives 5-10% of real traffic. Always define explicit promotion criteria (epsilon AUC improvement + non-overlapping CI + no fairness regression) before running the experiment — not after seeing results.

**Never Delete Registry Entries**
Deleted versions break audit trails, compliance requirements, and rollback capability. Archive with a deprecation note. The registry is a permanent ledger of what was deployed and when.

## Quick Start

```bash
pip install mlflow wandb huggingface_hub
```

```python
import mlflow
mlflow.set_tracking_uri("http://mlflow-server:5000")

with mlflow.start_run():
    mlflow.log_metric("val_auc", 0.87)
    mlflow.sklearn.log_model(model, "model",
                             registered_model_name="my-model")
```
