#!/usr/bin/env bash
# libre-mlops-hooks: SessionStart
#
# Looks at the project Claude Code just opened. When it finds ML markers
# (framework dependencies, MLproject, dvc.yaml, an mlruns folder, a Feast
# feature_store.yaml), it prints one line of context: what it found and which
# LibreMLOps plugins fit. Projects without ML markers get no output.
# Reads only; writes no files.
set -uo pipefail

input="$(cat)"
dir=""
command -v jq >/dev/null 2>&1 && dir="$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null)"
[[ -n "$dir" && -d "$dir" ]] || dir="$PWD"

deps=""
for m in requirements.txt requirements-dev.txt requirements/base.txt pyproject.toml setup.py setup.cfg environment.yml environment.yaml Pipfile; do
  [[ -f "$dir/$m" ]] && deps+="$(tr '[:upper:]' '[:lower:]' < "$dir/$m" 2>/dev/null)"$'\n'
done
has() { grep -qE "(^|[^a-z0-9_-])($1)([^a-z0-9_-]|$)" <<<"$deps"; }

found=(); plugins=()
add() { found+=("$1"); shift; plugins+=("$@"); }

has 'torch|pytorch-lightning|lightning' && add PyTorch pytorch-patterns model-training
has 'tensorflow|keras|tfx' && add TensorFlow tensorflow-patterns model-training
has 'transformers|peft|trl|bitsandbytes' && add "Hugging Face" llm-fine-tuning gpu-optimization
has 'deepspeed|accelerate' && add "multi-GPU training" distributed-training
has 'langchain|llama-index|llama_index|llamaindex|ragas' && add "RAG or LLM app" rag-architecture prompt-engineering
has 'dspy|dspy-ai|instructor' && add "prompt tooling" prompt-engineering
has 'pgvector|pinecone|pinecone-client|qdrant-client|weaviate-client|chromadb|faiss-cpu|faiss-gpu|pymilvus' && add "vector store client" vector-databases
has 'mlflow' && add MLflow mlflow-integration experiment-tracking model-registry
has 'wandb|neptune|clearml' && add "experiment tracker" experiment-tracking
has 'dvc' && add DVC data-versioning
has 'feast' && add Feast feature-engineering
has 'evidently|nannyml|whylogs' && add "drift monitoring" model-monitoring
has 'great-expectations|great_expectations|deepchecks' && add "data validation" ml-testing
has 'bentoml|tritonclient|torchserve|onnxruntime' && add "model serving" model-deployment
has 'apache-beam|pyspark|dbt-core' && add "data pipeline framework" data-pipelines
has 'label-studio|snorkel|cleanlab' && add "labeling tools" data-labeling
has 'scikit-learn|sklearn|xgboost|lightgbm|catboost' && add "classical ML" model-evaluation ml-testing

[[ -f "$dir/MLproject" ]] && add "MLproject file" mlflow-integration
[[ -d "$dir/mlruns" ]] && add "mlruns folder" experiment-tracking
[[ -f "$dir/dvc.yaml" || -d "$dir/.dvc" ]] && add "DVC repo" data-versioning
[[ -f "$dir/feature_store.yaml" || -f "$dir/feature_repo/feature_store.yaml" ]] && add "Feast repo" feature-engineering

(( ${#found[@]} > 0 )) || exit 0

extras=()
[[ -d "$dir/notebooks" ]] && extras+=(notebooks)
[[ -d "$dir/models" ]] && extras+=("models folder")
[[ -d "$dir/data" ]] && extras+=("data folder")

join() { local out="" x; for x in "$@"; do out+="${out:+, }$x"; done; echo "$out"; }
uniq_found="$(join $(printf '%s\n' "${found[@]}" | awk '!seen[$0]++' | tr ' ' '_') | tr '_' ' ')"
uniq_plugins="$(join $(printf '%s\n' "${plugins[@]}" | sort -u))"
line="LibreMLOps: ML project detected ($uniq_found"
(( ${#extras[@]} )) && line+="; $(join "${extras[@]}")"
line+="). Relevant plugins: $uniq_plugins."
echo "$line"
exit 0
