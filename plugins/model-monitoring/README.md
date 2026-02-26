# model-monitoring

Data drift detection (PSI, KS, Wasserstein), concept drift, performance estimation without ground truth (NannyML CBPE), Evidently reports, Prometheus alerting, and alert fatigue management.

## What This Plugin Does

Covers production ML health monitoring: PSI/KS/Wasserstein drift computation across numeric and categorical features, Evidently automated drift TestSuites for CI gates, NannyML CBPE for estimating model performance before labels arrive, whylogs distribution sketching for WhyLabs integration, Prometheus metrics instrumentation for Grafana dashboards, and Alertmanager routing rules that avoid on-call fatigue.

## When to Use

- Computing PSI per feature to detect upstream data distribution changes
- Running an automated drift gate in CI before promoting a new data batch
- Estimating model AUC/F1 in production without waiting for ground truth labels
- Setting up Evidently HTML reports for weekly model health reviews
- Instrumenting a serving endpoint with Prometheus histogram metrics for score distribution
- Writing Alertmanager rules that fire after N consecutive windows (not on transient spikes)
- Distinguishing data drift (P(X) shift) from concept drift (P(Y|X) shift)

## Components

| Component | Description |
|-----------|-------------|
| `agents/model-monitor` | Expert in Evidently, NannyML, WhyLabs, drift statistics, alert engineering |
| `skills/model-monitoring-patterns` | PSI implementation, Evidently TestSuite, NannyML CBPE, whylogs profiles, Prometheus instrumentation |
| `commands/monitor-model` | `/monitor-model drift\|performance\|alert\|report` workflows |

## Key Concepts

**PSI vs KS Test**
PSI (Population Stability Index) is threshold-based and interpretable: < 0.1 stable, 0.1–0.25 investigate, > 0.25 significant. KS test provides a p-value but is sensitive to sample size — large samples make tiny differences statistically significant. Use PSI for operational decisions; KS for statistical rigor.

**Performance Estimation Without Labels**
Ground truth labels in production arrive late (fraud: 30 days, churn: 90 days). NannyML CBPE uses calibrated prediction probabilities to estimate AUC/F1/precision/recall immediately. Requires a well-calibrated model — check ECE before relying on CBPE estimates.

**Data Drift vs Concept Drift**
Data drift: input feature distributions change. Detectable without labels. Does not necessarily cause model degradation if the model generalizes. Concept drift: P(Y|X) changes — the same features now predict different outcomes. Always causes model degradation. Requires labels or proxy metrics to detect.

**Alert Fatigue**
50 features × 3 drift metrics × 0.05 significance = expect 7.5 false alarms per window by chance. Require N-of-M consecutive windows above threshold. Use composite drift score. Route P2 drift alerts to Slack digest, not PagerDuty.

## Quick Start

```bash
pip install evidently nannyml whylogs prometheus-client scipy
```

```python
from evidently.report import Report
from evidently.metric_preset import DataDriftPreset

report = Report(metrics=[DataDriftPreset()])
report.run(reference_data=reference_df, current_data=current_df)
report.save_html("drift.html")
```
