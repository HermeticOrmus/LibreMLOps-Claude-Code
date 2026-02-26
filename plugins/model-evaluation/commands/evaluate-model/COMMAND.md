# /evaluate-model

Compute classification metrics, calibration, fairness, sliced evaluation, and LLM output quality.

## Trigger

`/evaluate-model [action] [options]`

## Actions

- `metrics` - Compute full classification metrics with confidence intervals
- `fairness` - Evaluate demographic parity and equalized odds across subgroups
- `calibrate` - Analyze and correct probability calibration
- `compare` - Statistical comparison between two model versions

## Examples

### metrics — Full classification report

```python
import numpy as np
from sklearn.metrics import (
    classification_report, roc_auc_score, average_precision_score,
    matthews_corrcoef, brier_score_loss, confusion_matrix
)

def evaluate_classifier(y_true, y_pred, y_proba, label_names=None):
    proba_pos = y_proba[:, 1] if y_proba.ndim == 2 else y_proba

    print("=== Classification Report ===")
    print(classification_report(y_true, y_pred, target_names=label_names))

    print("=== Key Metrics ===")
    print(f"MCC:         {matthews_corrcoef(y_true, y_pred):.4f}")
    print(f"AUC-ROC:     {roc_auc_score(y_true, proba_pos):.4f}")
    print(f"AUC-PR:      {average_precision_score(y_true, proba_pos):.4f}")
    print(f"Brier Score: {brier_score_loss(y_true, proba_pos):.4f} (lower is better)")

    print("\n=== Confusion Matrix ===")
    cm = confusion_matrix(y_true, y_pred)
    print(cm)
    tn, fp, fn, tp = cm.ravel()
    print(f"Precision: {tp/(tp+fp):.4f} | Recall: {tp/(tp+fn):.4f} | Specificity: {tn/(tn+fp):.4f}")

    # Bootstrap CI for AUC
    rng = np.random.default_rng(42)
    boot_aucs = [
        roc_auc_score(y_true[idx := rng.integers(0, len(y_true), len(y_true))], proba_pos[idx])
        for _ in range(1000)
        if len(np.unique(y_true[rng.integers(0, len(y_true), len(y_true))])) > 1
    ]
    print(f"\nAUC-ROC 95% CI: [{np.percentile(boot_aucs, 2.5):.4f}, {np.percentile(boot_aucs, 97.5):.4f}]")

evaluate_classifier(y_test, y_pred, y_proba_test, label_names=["no-churn", "churn"])
```

### fairness — Demographic parity check

```python
from fairlearn.metrics import (
    demographic_parity_difference,
    equalized_odds_difference,
    MetricFrame
)
from sklearn.metrics import accuracy_score, f1_score

# sensitive_features: array with group labels (e.g., gender, age_group)
dp_diff = demographic_parity_difference(y_true, y_pred,
                                         sensitive_features=user_segment)
eo_diff = equalized_odds_difference(y_true, y_pred,
                                     sensitive_features=user_segment)

print(f"Demographic parity difference: {dp_diff:.4f}")
print(f"  < 0.10: acceptable | > 0.10: investigate | > 0.20: mitigate")
print(f"Equalized odds difference:     {eo_diff:.4f}")

# Per-group breakdown
mf = MetricFrame(
    metrics={"accuracy": accuracy_score, "f1": f1_score,
             "positive_rate": lambda yt, yp: yp.mean()},
    y_true=y_true, y_pred=y_pred,
    sensitive_features=user_segment
)
print("\nPer-group metrics:")
print(mf.by_group.to_string())
print(f"\nMin accuracy: {mf.by_group['accuracy'].min():.4f} "
      f"(group: {mf.by_group['accuracy'].idxmin()})")
```

### calibrate — Check and fix calibration

```python
from sklearn.calibration import calibration_curve, CalibratedClassifierCV
from sklearn.metrics import brier_score_loss
import matplotlib.pyplot as plt

# Plot reliability diagram
frac_pos, mean_pred = calibration_curve(y_val, model.predict_proba(X_val)[:, 1], n_bins=10)
ece_before = brier_score_loss(y_val, model.predict_proba(X_val)[:, 1])

# Isotonic regression calibration
calibrated = CalibratedClassifierCV(model, method="isotonic", cv="prefit")
calibrated.fit(X_val, y_val)

frac_pos_cal, mean_pred_cal = calibration_curve(y_val, calibrated.predict_proba(X_val)[:, 1], n_bins=10)
ece_after = brier_score_loss(y_val, calibrated.predict_proba(X_val)[:, 1])

print(f"Brier score before: {ece_before:.4f}")
print(f"Brier score after:  {ece_after:.4f}")
print(f"Improvement: {(ece_before - ece_after)/ece_before*100:.1f}%")
```

### compare — Statistical comparison

```python
from scipy.stats import wilcoxon
import numpy as np

def compare_models_bootstrap(
    y_true: np.ndarray,
    proba_a: np.ndarray,
    proba_b: np.ndarray,
    n_bootstrap: int = 10000,
    alpha: float = 0.05
) -> dict:
    """Bootstrap test: is model B significantly better than model A?"""
    from sklearn.metrics import roc_auc_score
    rng = np.random.default_rng(42)
    diffs = []
    for _ in range(n_bootstrap):
        idx = rng.integers(0, len(y_true), len(y_true))
        if len(np.unique(y_true[idx])) < 2:
            continue
        auc_a = roc_auc_score(y_true[idx], proba_a[idx])
        auc_b = roc_auc_score(y_true[idx], proba_b[idx])
        diffs.append(auc_b - auc_a)

    mean_diff = np.mean(diffs)
    ci_low, ci_high = np.percentile(diffs, [alpha/2*100, (1-alpha/2)*100])
    p_value = np.mean(np.array(diffs) <= 0)  # one-sided: P(B not better than A)

    return {
        "auc_a": round(roc_auc_score(y_true, proba_a), 4),
        "auc_b": round(roc_auc_score(y_true, proba_b), 4),
        "mean_improvement": round(mean_diff, 4),
        "ci_95": (round(ci_low, 4), round(ci_high, 4)),
        "p_value": round(p_value, 4),
        "significant": p_value < alpha and ci_low > 0,
    }

result = compare_models_bootstrap(y_test, proba_model_a, proba_model_b)
print(f"A: {result['auc_a']:.4f} | B: {result['auc_b']:.4f}")
print(f"Improvement: {result['mean_improvement']:+.4f} (95% CI: {result['ci_95']})")
print(f"Statistically significant: {result['significant']} (p={result['p_value']:.4f})")
```

## Options

- `--test-data <path>` - Path to test dataset (Parquet/CSV)
- `--model-path <path>` - Path to model artifact
- `--label-col <col>` - Label column name (default: label)
- `--proba-col <col>` - Probability column name (for pre-computed probabilities)
- `--sensitive-feature <col>` - Column for fairness evaluation
- `--n-bootstrap <n>` - Bootstrap iterations for CI (default: 1000)
- `--threshold <float>` - Classification threshold (default: 0.5)
