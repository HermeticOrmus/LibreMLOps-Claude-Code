# model-evaluation

Classification metrics (MCC, AUC-PR, calibration), fairness (Fairlearn, AI Fairness 360), sliced evaluation, LLM evaluation (BERTScore, RAGAS), and statistical comparison.

## What This Plugin Does

Covers comprehensive model evaluation beyond accuracy: all sklearn classification metrics with bootstrap confidence intervals, probability calibration analysis and correction, sliced evaluation by subgroup to find systematic failures, fairness metrics (demographic parity, equalized odds), LLM output quality with BLEU/ROUGE/BERTScore/RAGAS, and statistical comparison between model versions.

## When to Use

- Computing a full evaluation report for a classification model (F1, MCC, AUC-ROC, AUC-PR, calibration)
- Finding performance gaps by demographic or behavioral subgroup
- Measuring demographic parity and equalized odds with Fairlearn
- Applying Platt scaling or isotonic regression to calibrate probabilities
- Evaluating generated text (summarization, translation) with BERTScore or RAGAS
- Statistically testing whether a new model is significantly better than the current one
- Building an evaluation framework that runs in CI before every deployment

## Components

| Component | Description |
|-----------|-------------|
| `agents/model-evaluator` | Expert in classification metrics, calibration, fairness, LLM evaluation, statistical testing |
| `skills/model-evaluation-patterns` | Code patterns: full report, calibration, sliced eval, fairness, BERTScore, bootstrap comparison |
| `commands/evaluate-model` | `/evaluate-model metrics\|fairness\|calibrate\|compare` workflows |

## Key Concepts

**MCC Over Accuracy**
Matthews Correlation Coefficient is the best single metric for binary classification on imbalanced datasets. Unlike F1, it accounts for all four cells of the confusion matrix. Range: -1 (worst) to +1 (perfect). Use when classes are imbalanced.

**AUC-PR for Rare Events**
For fraud detection, rare disease, anomaly detection — class imbalance makes AUC-ROC misleading. AUC-PR (area under precision-recall curve) is more informative when the positive class is rare.

**Calibration**
A model with AUC=0.95 but ECE=0.20 generates probabilities that don't match actual positive rates. If downstream decisions are threshold-based, bad calibration causes systematic errors. Check ECE; fix with isotonic regression.

**Sliced Evaluation**
Overall 92% accuracy can hide 65% accuracy on a critical subgroup. Always break down metrics by demographic segments, confidence bins, and temporal windows. Never approve a model for production without sliced evaluation.

**Bootstrap Confidence Intervals**
Report metrics with 95% confidence intervals. A 0.003 F1 improvement without overlapping CIs is meaningful. The same difference with overlapping CIs is noise.

## Quick Start

```bash
pip install scikit-learn fairlearn evaluate ragas scipy
```

```python
from sklearn.metrics import roc_auc_score, matthews_corrcoef, brier_score_loss
print(f"AUC: {roc_auc_score(y_true, y_proba):.4f}")
print(f"MCC: {matthews_corrcoef(y_true, y_pred):.4f}")
print(f"Brier: {brier_score_loss(y_true, y_proba):.4f}")
```
