# /label-data

Manage annotation pipelines, label quality, and dataset export workflows.

## Trigger

`/label-data [action] [options]`

## Actions

- `plan` - Design annotation schema, guidelines, and IAA measurement strategy
- `upload` - Prepare and upload tasks to Label Studio or export to annotation platform format
- `review` - Compute IAA, flag low-quality annotators, surface disagreements
- `export` - Export labeled data with quality filters and format conversion

## Examples

### plan — Design annotation schema
```bash
/label-data plan --task sentiment_classification --classes positive,negative,neutral --annotators 3
```
Output: annotation guideline template, decision tree for edge cases, IAA measurement plan, gold label injection strategy

### upload — Prepare Label Studio tasks
```python
# Label Studio JSON task format
tasks = [
    {
        "data": {
            "text": "The product quality exceeded my expectations.",
            "meta": {"source": "amazon_reviews", "product_id": "B001234"}
        }
    },
    # ... more tasks
]

# Upload via Label Studio SDK
from label_studio_sdk import Client

ls = Client(url="http://localhost:8080", api_key="YOUR_API_KEY")
project = ls.get_project(project_id=1)
project.import_tasks(tasks)

print(f"Uploaded {len(tasks)} tasks to project {project.id}")
```

### review — Compute IAA across annotators
```python
import pandas as pd
from sklearn.metrics import cohen_kappa_score

# Export annotations from Label Studio
annotations = project.export_tasks(export_type="JSON_MIN")

# Build annotation matrix
records = []
for task in annotations:
    for ann in task.get("annotations", []):
        records.append({
            "task_id": task["id"],
            "annotator": ann["completed_by"],
            "label": ann["result"][0]["value"]["choices"][0]
        })

df = pd.DataFrame(records)
pivot = df.pivot(index="task_id", columns="annotator", values="label")

# Pairwise kappa
annotators = pivot.columns.tolist()
for i, a1 in enumerate(annotators):
    for a2 in annotators[i+1:]:
        shared = pivot[[a1, a2]].dropna()
        kappa = cohen_kappa_score(shared[a1], shared[a2])
        status = "PASS" if kappa > 0.8 else "REVIEW" if kappa > 0.6 else "FAIL"
        print(f"{a1} vs {a2}: κ={kappa:.3f} [{status}] (n={len(shared)})")
```

### export — Export with quality filters
```python
from label_studio_sdk import Client
import json

ls = Client(url="http://localhost:8080", api_key="YOUR_API_KEY")
project = ls.get_project(project_id=1)

# Export only tasks with full annotator agreement
tasks = project.export_tasks(export_type="JSON_MIN")

clean_tasks = []
for task in tasks:
    annotations = task.get("annotations", [])
    if len(annotations) < 2:
        continue
    labels = [a["result"][0]["value"]["choices"][0] for a in annotations]
    # Require unanimous agreement for clean export
    if len(set(labels)) == 1:
        clean_tasks.append({
            "text": task["data"]["text"],
            "label": labels[0]
        })

print(f"Clean examples: {len(clean_tasks)} / {len(tasks)} ({len(clean_tasks)/len(tasks):.1%})")

with open("labeled_dataset_v1.json", "w") as f:
    json.dump(clean_tasks, f, indent=2)
```

## CVAT Export Format (Computer Vision)

```bash
# Export COCO format from CVAT
curl -X GET "http://localhost:8080/api/tasks/{task_id}/dataset?format=COCO+1.0" \
  -H "Authorization: Token YOUR_TOKEN" \
  --output dataset_coco.zip

# Validate COCO annotation schema
python -c "
import json
with open('annotations/instances_train.json') as f:
    coco = json.load(f)
print('Images:', len(coco['images']))
print('Annotations:', len(coco['annotations']))
print('Categories:', [c['name'] for c in coco['categories']])
"
```

## Label Distribution Report

```python
from collections import Counter
import matplotlib.pyplot as plt

def label_distribution_report(tasks: list, label_field: str = "label"):
    labels = [t[label_field] for t in tasks if label_field in t]
    counts = Counter(labels)
    total = sum(counts.values())

    print("Label Distribution")
    print("-" * 40)
    for label, count in sorted(counts.items(), key=lambda x: -x[1]):
        pct = count / total * 100
        bar = "#" * int(pct / 2)
        print(f"{label:20s} {count:6d} ({pct:5.1f}%) {bar}")

    imbalance_ratio = max(counts.values()) / min(counts.values())
    if imbalance_ratio > 10:
        print(f"\nWARNING: Imbalance ratio {imbalance_ratio:.1f}x — consider oversampling minority class")
    return counts
```

## Options

- `--project-id <id>` - Label Studio project ID
- `--min-kappa <float>` - Minimum acceptable IAA (default: 0.8)
- `--gold-rate <float>` - Gold label injection rate (default: 0.1)
- `--export-format <fmt>` - Output format: json, csv, coco, voc, spacy
- `--agreement-threshold <float>` - Minimum annotator agreement for export (default: 1.0 = unanimous)
