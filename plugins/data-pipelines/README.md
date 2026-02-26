# data-pipelines

Batch and streaming ML data pipelines using Apache Beam, Spark, dbt, and orchestrators (Airflow/Prefect/Dagster).

## What This Plugin Does

Covers ML data engineering from source to feature store: pipeline design, transform implementation (Beam DoFn, Spark DataFrame, dbt models), orchestration, data validation with Great Expectations, and backfill strategies. The core discipline is building pipelines that fail loudly, run idempotently, and produce point-in-time correct features.

## When to Use

- Building batch feature pipelines on Apache Beam or Spark
- Streaming feature computation via Kafka + Flink
- SQL-based feature engineering with dbt incremental models
- Orchestrating ML pipelines in Airflow, Prefect, or Dagster
- Adding data quality checks with Great Expectations
- Planning backfill for historical feature computation
- Debugging training-serving skew from pipeline issues

## Components

| Component | Description |
|-----------|-------------|
| `agents/ml-data-engineer` | Expert in Beam, Spark, dbt, orchestrators, streaming, data validation |
| `skills/ml-pipeline-patterns` | Code patterns: Beam DoFn, branching pipelines, dbt incremental, backfill |
| `commands/ml-pipeline` | `/ml-pipeline build\|test\|backfill\|monitor` workflows |

## Key Concepts

**Batch vs Streaming**
Batch pipelines (Beam/Spark) compute features over historical windows. Streaming pipelines (Flink/Spark Streaming) compute features in near-real-time. Many production systems need both — identical features computed two ways (the lambda architecture problem). Beam's unified model solves this partially.

**Point-in-Time Correctness**
Features must only use data available at label timestamp. Violating this produces leakage: models look great in training, fail in production. Always filter `WHERE event_ts < label_ts` when joining features to labels.

**Idempotency**
Every pipeline step should be safe to re-run without side effects. Check for existing output before writing. Use UPSERT semantics in databases. This makes backfill and recovery reliable.

**Data Validation**
Great Expectations provides schema, range, uniqueness, and distribution checks. Fail the pipeline early on bad data rather than propagating corruption downstream to model training.

## Quick Start

```bash
pip install apache-beam great-expectations prefect dbt-core dbt-bigquery
```

```python
# Minimal Beam pipeline
import apache_beam as beam

with beam.Pipeline() as p:
    (p
     | beam.io.ReadFromParquet('input/*.parquet')
     | beam.Map(lambda x: {**x, 'feature': x['value'] * 2})
     | beam.io.WriteToParquet('output/'))
```
