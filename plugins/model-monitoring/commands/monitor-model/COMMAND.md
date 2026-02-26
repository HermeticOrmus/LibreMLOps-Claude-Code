# /monitor-model

Detect data drift, estimate performance without ground truth, set up alerts, and generate monitoring reports.

## Trigger

`/monitor-model [action] [options]`

## Actions

- `drift` - Compute PSI/KS/Wasserstein drift across all features vs reference
- `performance` - Estimate model performance metrics without ground truth labels
- `alert` - Configure Prometheus alerting rules and Alertmanager routing
- `report` - Generate Evidently HTML report for a production window

## Examples

### drift — Feature drift computation

```python
from evidently.report import Report
from evidently.metric_preset import DataDriftPreset
from evidently import ColumnMapping

column_mapping = ColumnMapping(
    target="label",
    prediction="predicted_label",
    numerical_features=["age", "income", "tenure_days"],
    categorical_features=["country", "device_type"],
)

report = Report(metrics=[DataDriftPreset(stattest="psi", stattest_threshold=0.1)])
report.run(reference_data=reference_df,
           current_data=current_df,
           column_mapping=column_mapping)

# Get drift results programmatically
result = report.as_dict()
drifted = [
    col for col, data in result["metrics"][0]["result"]["drift_by_columns"].items()
    if data["drift_detected"]
]
print(f"Drifted features ({len(drifted)}): {drifted}")
report.save_html("drift_report.html")
```

### performance — Estimate AUC/F1 without labels

```python
import nannyml as nml

estimator = nml.CBPE(
    y_pred_proba="y_pred_proba",
    y_pred="y_pred",
    y_true="label",
    timestamp_column_name="timestamp",
    metrics=["roc_auc", "f1", "precision", "recall"],
    chunk_size=500,
    problem_type="binary_classification",
)
estimator.fit(reference_df)

results = estimator.estimate(production_df)
df = results.to_df()

# Flag estimated degradation
for metric in ["roc_auc", "f1"]:
    latest = df[metric].iloc[-1]
    threshold = df[metric].quantile(0.05)  # bottom 5% of estimates = alarm
    if latest < threshold:
        print(f"WARN: Estimated {metric}={latest:.4f} below alarm threshold {threshold:.4f}")
```

### alert — Prometheus alerting rules

```yaml
# monitoring/alerts.yaml
groups:
  - name: model-monitoring
    rules:
      - alert: HighFeatureDrift
        expr: feature_psi > 0.25
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Feature {{ $labels.feature }} PSI={{ $value | printf \"%.3f\" }}"
          description: "PSI > 0.25 indicates significant distribution shift"

      - alert: ModelPredictionErrorSpike
        expr: rate(model_predictions_total{outcome="error"}[5m]) > 0.05
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Model error rate exceeds 5%"

      - alert: LowPredictionVolume
        expr: rate(model_predictions_total[10m]) < 1
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Prediction volume dropped — possible upstream data issue"
```

### report — Weekly monitoring digest

```python
from evidently.report import Report
from evidently.metric_preset import DataDriftPreset, DataQualityPreset, TargetDriftPreset
import datetime

def weekly_monitoring_report(reference_df, current_df, column_mapping, output_path):
    report = Report(metrics=[
        DataQualityPreset(),
        DataDriftPreset(stattest="psi"),
        TargetDriftPreset(),
    ])
    report.run(reference_data=reference_df,
               current_data=current_df,
               column_mapping=column_mapping)
    report.save_html(output_path)
    print(f"Report saved to {output_path}")

    result = report.as_dict()
    summary = {
        "n_reference": len(reference_df),
        "n_current": len(current_df),
        "drifted_features": sum(
            1 for col, data in
            result["metrics"][1]["result"]["drift_by_columns"].items()
            if data["drift_detected"]
        ),
        "generated_at": datetime.datetime.utcnow().isoformat(),
    }
    return summary

summary = weekly_monitoring_report(
    reference_df=reference_df,
    current_df=last_7_days_df,
    column_mapping=column_mapping,
    output_path="reports/monitoring_week_2024_w52.html"
)
print(summary)
```

## Options

- `--reference-path <path>` - Parquet/CSV path for reference data
- `--current-path <path>` - Parquet/CSV path for current production window
- `--chunk-size <n>` - Events per monitoring window for NannyML (default: 500)
- `--threshold-psi <float>` - PSI alert threshold (default: 0.25)
- `--threshold-ks <float>` - KS p-value threshold (default: 0.05)
- `--output-dir <path>` - Directory for HTML reports and JSON summaries
- `--model-version <str>` - Tag reports with model version label
