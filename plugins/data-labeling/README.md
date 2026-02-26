# data-labeling

Annotation pipeline management, label quality assurance, and weak supervision for ML datasets.

## What This Plugin Does

Covers the full annotation lifecycle: schema design, platform integration (Label Studio, Scale AI, Labelbox, CVAT), inter-annotator agreement measurement, active learning for efficient labeling, and weak supervision via Snorkel. The primary goal is maximizing label quality per annotation dollar.

## When to Use

- Designing annotation guidelines and label taxonomies
- Setting up or auditing Label Studio / CVAT annotation projects
- Measuring inter-annotator agreement (Cohen's kappa, Fleiss' kappa, Krippendorff's alpha)
- Implementing active learning sampling to reduce labeling cost
- Using Snorkel labeling functions for programmatic weak supervision
- Detecting and correcting label errors in existing datasets (Cleanlab)
- Exporting labeled datasets with quality filters

## Components

| Component | Description |
|-----------|-------------|
| `agents/data-labeling-engineer` | Expert in annotation platforms, IAA measurement, active learning, Snorkel |
| `skills/labeling-patterns` | Code patterns: active learning sampling, LF pipelines, IAA computation, Cleanlab |
| `commands/label-data` | `/label-data plan\|upload\|review\|export` workflows |

## Key Concepts

**Inter-Annotator Agreement (IAA)**
Cohen's kappa corrects for chance agreement. κ > 0.8 is the production threshold. Measure per class, per annotator, per batch — not just overall.

**Active Learning**
Don't label randomly. Uncertainty sampling (label what the model is most confused about) plus core-set diversity selection cuts labeling cost by 3–5x for most classification tasks.

**Weak Supervision (Snorkel)**
Write heuristic labeling functions in Python. Snorkel's label model learns which functions to trust, producing probabilistic labels that beat majority vote. Scales to millions of examples without human annotation.

**Label Error Detection (Cleanlab)**
Use confident learning (Northcutt et al. 2021) to find mislabeled examples. Requires cross-validation predicted probabilities, not retraining. Typical error rate in real-world datasets: 3–10%.

## Supported Platforms

- Label Studio (self-hosted, open-source)
- CVAT (computer vision, self-hosted)
- Scale AI (managed, via API)
- Labelbox (managed, via API)
- Prodigy (Python-first, with spaCy)

## Quick Start

```bash
pip install label-studio label-studio-sdk snorkel cleanlab scikit-learn
label-studio start
```

```python
from sklearn.metrics import cohen_kappa_score
kappa = cohen_kappa_score(annotator_1_labels, annotator_2_labels)
print(f"κ = {kappa:.3f} ({'PASS' if kappa > 0.8 else 'REVIEW'})")
```
