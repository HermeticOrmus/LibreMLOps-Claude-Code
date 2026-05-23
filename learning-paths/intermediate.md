# Intermediate — pipelines + registry + drift

## Pipelines

Airflow / Dagster / Prefect / Argo. Pick one. The patterns matter more than the tool.

## Registry

MLflow Model Registry (free), Weights & Biases (paid), SageMaker Model Registry (AWS-native). Track: model version, training data version, code version, eval metrics, lineage.

## Drift monitoring

- **Data drift**: input distribution changes (PSI, KL divergence)
- **Concept drift**: input → output relationship changes (label correlations)
- **Performance drift**: actual model quality degrades (requires labels)

Alert on each. Retrain on schedule + on drift detection.

## Next: [Advanced](advanced.md)
