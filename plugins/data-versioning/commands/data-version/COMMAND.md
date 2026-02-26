# /data-version

Manage dataset versioning, DVC pipelines, and data lineage with Git + DVC workflow.

## Trigger

`/data-version [action] [options]`

## Actions

- `init` - Initialize DVC in a repo with remote storage configuration
- `track` - Add files to DVC tracking and commit pointer to Git
- `push` - Push data to remote storage and sync with team
- `diff` - Compare data, params, and metrics across versions

## Examples

### init — Set up DVC in a new ML project

```bash
# Initialize Git + DVC
git init my-ml-project && cd my-ml-project
dvc init
git add .dvc/
git commit -m "chore: initialize DVC"

# Configure S3 remote
dvc remote add -d s3remote s3://my-bucket/dvc-cache
dvc remote modify s3remote region us-east-1
# For GCS: dvc remote add -d gcpremote gs://my-bucket/dvc-cache
# For Azure: dvc remote add -d azremote azure://my-container/dvc-cache

git add .dvc/config
git commit -m "chore: configure DVC remote storage"

# Create directory structure
mkdir -p data/{raw,processed,splits} models metrics src
cat > .dvcignore << 'EOF'
# Exclude from DVC tracking
*.pyc
__pycache__/
.ipynb_checkpoints/
EOF

# Initialize params and pipeline
cat > params.yaml << 'EOF'
preprocess:
  max_features: 10000
  test_size: 0.2
  random_state: 42
train:
  learning_rate: 3.0e-4
  batch_size: 32
  epochs: 20
EOF

git add params.yaml .dvcignore
git commit -m "chore: add DVC params and ignore configuration"
```

### track — Version a dataset

```bash
# Track a large file
dvc add data/raw/dataset.parquet
git add data/raw/dataset.parquet.dvc data/raw/.gitignore
git commit -m "data: add raw training dataset (n=500k)"
dvc push

# Track entire directory
dvc add data/raw/images/
git add data/raw/images.dvc data/raw/.gitignore
git commit -m "data: add image dataset v1 (n=10k images)"
dvc push

# Tag a data release
git tag -a "data-v1.0" -m "Initial training dataset release"
git push origin data-v1.0
dvc push  # ensure data is pushed before sharing tag
```

### push — Sync data with team

```bash
# Push all tracked data to remote
dvc push

# Pull data for a specific commit (teammate workflow)
git clone https://github.com/org/repo.git
cd repo
git checkout data-v1.0
dvc pull

# Pull only specific files
dvc pull data/raw/train.parquet.dvc

# Check what's out of sync
dvc status --cloud
```

### diff — Compare versions

```bash
# Compare current state to HEAD
dvc diff

# Compare data between two commits
dvc diff HEAD~5 HEAD

# Compare parameters between commits
dvc params diff HEAD~1
# Output:
#   Path           Param                    Old      New
#   params.yaml    train.learning_rate      1e-3     3e-4

# Compare metrics between experiments
dvc metrics diff HEAD~1
# Output:
#   Path               Metric     Old      New      Change
#   metrics/eval.json  f1         0.847    0.863    0.016

# Show full experiment table
dvc exp show --num 10

# Reproduce pipeline from clean state
dvc repro --force

# Check pipeline status
dvc status
```

## DVC Pipeline Example

```yaml
# dvc.yaml — defines reproducible ML pipeline
stages:
  preprocess:
    cmd: python src/preprocess.py
    deps: [src/preprocess.py, data/raw/dataset.parquet]
    params: [params.yaml: [preprocess]]
    outs: [data/processed/train.parquet, data/processed/val.parquet]

  train:
    cmd: python src/train.py
    deps: [src/train.py, data/processed/train.parquet]
    params: [params.yaml: [train]]
    outs: [models/model.pt]
    metrics: [metrics/eval.json: {cache: false}]
```

```bash
dvc repro          # run changed stages
dvc dag            # visualize pipeline
dvc lock           # view dvc.lock (pinned hashes of all outputs)
```

## Options

- `--remote <name>` - DVC remote to push/pull from
- `--rev <git-ref>` - Git revision to compare against
- `--all-branches` - Show experiments across all branches
- `--num <n>` - Number of recent experiments to show
