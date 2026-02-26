# /ml-pipeline

Build, test, backfill, and monitor ML data pipelines with Apache Beam, Spark, dbt, and orchestrators.

## Trigger

`/ml-pipeline [action] [options]`

## Actions

- `build` - Scaffold or review a pipeline for the specified source and target
- `test` - Generate unit and integration tests for pipeline transforms
- `backfill` - Design or implement historical data recomputation
- `monitor` - Set up data freshness and quality monitoring

## Examples

### build — Apache Beam feature pipeline

```python
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions

class ComputeUserFeaturesFn(beam.DoFn):
    def process(self, element: dict):
        user_id = element['user_id']
        events = element['events']
        yield {
            'user_id': user_id,
            'event_count_7d': len([e for e in events if e['days_ago'] <= 7]),
            'event_count_30d': len(events),
            'last_event_type': events[0]['type'] if events else None,
        }

def run(argv=None):
    options = PipelineOptions(argv, save_main_session=True)
    with beam.Pipeline(options=options) as p:
        (
            p
            | 'ReadEvents' >> beam.io.ReadFromParquet('gs://data/events/*.parquet')
            | 'GroupByUser' >> beam.GroupByKey()
            | 'ComputeFeatures' >> beam.ParDo(ComputeUserFeaturesFn())
            | 'WriteFeatures' >> beam.io.WriteToParquet('gs://features/users/')
        )

if __name__ == '__main__':
    run()
```

```bash
# Run locally with DirectRunner
python pipeline.py --runner=DirectRunner --input=data/events.parquet

# Run on Dataflow
python pipeline.py \
  --runner=DataflowRunner \
  --project=my-project \
  --region=us-central1 \
  --temp_location=gs://my-bucket/temp \
  --staging_location=gs://my-bucket/staging
```

### test — Unit test for DoFn transform

```python
import unittest
import apache_beam as beam
from apache_beam.testing.test_pipeline import TestPipeline
from apache_beam.testing.util import assert_that, equal_to

class TestComputeUserFeaturesFn(unittest.TestCase):
    def test_basic_feature_computation(self):
        input_data = [
            ('user_1', [
                {'type': 'purchase', 'days_ago': 1},
                {'type': 'view', 'days_ago': 5},
                {'type': 'view', 'days_ago': 20},
            ])
        ]
        expected = [{
            'user_id': 'user_1',
            'event_count_7d': 2,
            'event_count_30d': 3,
            'last_event_type': 'purchase',
        }]

        with TestPipeline() as p:
            result = (
                p
                | beam.Create(input_data)
                | beam.ParDo(ComputeUserFeaturesFn())
            )
            assert_that(result, equal_to(expected))

    def test_empty_events(self):
        with TestPipeline() as p:
            result = (
                p
                | beam.Create([('user_2', [])])
                | beam.ParDo(ComputeUserFeaturesFn())
            )
            assert_that(result, equal_to([{
                'user_id': 'user_2',
                'event_count_7d': 0,
                'event_count_30d': 0,
                'last_event_type': None,
            }]))
```

### backfill — Prefect backfill flow

```python
from prefect import flow, task
from datetime import date, timedelta

@task(retries=3, retry_delay_seconds=30)
def process_date_partition(run_date: date) -> int:
    output = f"s3://features/dt={run_date}/features.parquet"
    if s3_exists(output):
        return 0  # idempotent skip
    df = load_and_transform(run_date)
    write_parquet(df, output)
    return len(df)

@flow
def backfill(start: date, end: date):
    dates = [start + timedelta(d) for d in range((end - start).days + 1)]
    counts = process_date_partition.map(dates)
    total = sum(counts.result())
    print(f"Backfilled {total} rows across {len(dates)} partitions")

# Execute
backfill(start=date(2024, 1, 1), end=date(2024, 12, 31))
```

### monitor — Great Expectations checkpoint

```python
import great_expectations as gx

context = gx.get_context()

# Create checkpoint for daily validation
checkpoint_config = {
    "name": "daily_features_checkpoint",
    "validations": [{
        "batch_request": {
            "datasource_name": "s3_features",
            "data_connector_name": "inferred_data_connector",
            "data_asset_name": "user_features",
        },
        "expectation_suite_name": "user_features.critical"
    }],
    "action_list": [
        {"name": "store_validation_result", "action": {"class_name": "StoreValidationResultAction"}},
        {"name": "send_slack_notification_on_failure",
         "action": {
             "class_name": "SlackNotificationAction",
             "notify_on": "failure",
             "webhook": "${SLACK_WEBHOOK_URL}"
         }}
    ]
}

context.add_checkpoint(**checkpoint_config)
result = context.run_checkpoint(checkpoint_name="daily_features_checkpoint")
print(f"Validation: {'PASS' if result.success else 'FAIL'}")
```

## Options

- `--runner <runner>` - Beam runner: DirectRunner, DataflowRunner, SparkRunner
- `--source <uri>` - Input data URI (GCS, S3, local path)
- `--sink <uri>` - Output data URI
- `--start-date <date>` - Backfill start date (YYYY-MM-DD)
- `--end-date <date>` - Backfill end date (YYYY-MM-DD)
- `--parallelism <n>` - Parallel workers for backfill
- `--dry-run` - Validate pipeline without writing output
