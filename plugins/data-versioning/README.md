# data-versioning

Reproducible data management with DVC, Delta Lake, data lineage (OpenLineage/Marquez), and dataset cards.

## What This Plugin Does

Establishes the discipline of treating data as a first-class versioned artifact. Every training run should be reproducible from a Git commit hash alone — this plugin provides the patterns to achieve that. Covers DVC workflow, pipeline.yaml for reproducible pipelines, Delta Lake time travel, OpenLineage event emission, and versioned train/val/test splits.

## When to Use

- Setting up DVC in a new ML project with S3/GCS remote storage
- Versioning large datasets without putting them in Git
- Defining reproducible ML pipelines with `dvc.yaml`
- Comparing experiments: params diff, metrics diff, data diff
- Implementing time travel on dataset versions with Delta Lake
- Tracking data lineage across pipeline stages with OpenLineage
- Creating dataset cards for dataset documentation and governance
- Saving deterministic train/val/test splits for reproducibility

## Components

| Component | Description |
|-----------|-------------|
| `agents/data-version-engineer` | Expert in DVC, Delta Lake, Pachyderm, OpenLineage, Marquez |
| `skills/data-versioning-patterns` | Code patterns: Git+DVC workflow, dvc.yaml pipelines, Delta time travel, lineage emission |
| `commands/data-version` | `/data-version init\|track\|push\|diff` workflows |

## Key Concepts

**DVC: Git for Data**
DVC stores `.dvc` metafiles (containing md5 hash + size) in Git. The actual data bytes live in remote storage (S3, GCS, local). `git checkout` + `dvc checkout` gives you any historical data version.

**Pipeline Reproducibility**
`dvc.yaml` declares stages as (cmd, deps, params, outs, metrics). `dvc repro` runs only changed stages. `dvc.lock` pins exact hashes of every input and output — committed to Git as proof of what ran.

**Delta Lake Time Travel**
Delta Lake adds ACID transactions and an audit log to Parquet. `spark.read.format("delta").option("versionAsOf", 3).load(path)` gives exact data as it was at version 3. Critical for regulated environments.

**Data Lineage**
OpenLineage standard events track which jobs consumed which datasets to produce which outputs. Marquez is the open-source server. Airflow and Spark have native OpenLineage integrations.

## Quick Start

```bash
pip install dvc dvc-s3 openlineage-python
dvc init
dvc remote add -d myremote s3://bucket/dvc
dvc add data/train.parquet
git add data/train.parquet.dvc && git commit -m "data: version training set"
dvc push
```
