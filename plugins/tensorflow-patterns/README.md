# tensorflow-patterns

Keras functional API with multi-input models, tf.data pipeline with correct map/cache/shuffle/batch/prefetch ordering, custom layers and focal loss, SavedModel export with serving signatures, TFLite PTQ/QAT quantization, and TFX pipeline components.

## What This Plugin Does

Covers production TensorFlow: Keras functional API with numeric + categorical embedding inputs, tf.data pipeline construction in the correct performance order, TFRecord parsing with parallel interleave, custom Keras Layer/Loss/Metric subclasses with proper build/call/get_config, SavedModel export with tf.function serving signatures for TF Serving REST API, post-training quantization (float16 and int8 with calibration) and quantization-aware training (QAT) for TFLite edge deployment, and TFX Transform component for train/serve consistency.

## When to Use

- Building a multi-input Keras model combining numeric features and categorical embeddings
- Fixing a tf.data pipeline that has incorrect operation order (cache after shuffle, etc.)
- Parsing TFRecord files with tf.io.parse_single_example in parallel
- Writing a custom Keras layer with trainable weights via self.add_weight
- Exporting a model to SavedModel with an explicit serving signature for TF Serving
- Converting a SavedModel to TFLite with int8 quantization and calibration dataset
- Choosing between PTQ and QAT: PTQ for speed/simplicity, QAT for accuracy-critical tasks

## Components

| Component | Description |
|-----------|-------------|
| `agents/tensorflow-engineer` | Expert in Keras API, tf.data, SavedModel, TFLite, TFX, quantization |
| `skills/tensorflow-patterns` | Functional model, tf.data ordering, custom layers, SavedModel, TFLite PTQ/QAT |
| `commands/tensorflow` | `/tensorflow build\|optimize\|export\|serve` workflows |

## Key Concepts

**tf.data Pipeline Order**
The ordering `map → cache → shuffle → batch → prefetch` is not arbitrary. Caching before shuffle means each epoch sees the same shuffle order. Caching after batch wastes memory on padded batches. Prefetch must always be last. Getting this wrong silently reduces training throughput or causes data leakage.

**SavedModel vs HDF5**
TF Serving requires SavedModel format — it includes the computation graph, custom layer code, and serving signatures. HDF5 (`.h5`) saves only weights and architecture JSON. Never use `.h5` for serving. Use `.keras` (Keras v3) or SavedModel for any deployment use case.

**PTQ vs QAT**
Post-training quantization: fast to apply, no retraining, 2-5% accuracy drop on difficult tasks. Quantization-aware training: simulates quantization during training, produces weights robust to int8 errors, < 1% accuracy drop. Rule: try PTQ first. If accuracy loss exceeds tolerance, switch to QAT.

**Mixed Precision**
`tf.keras.mixed_precision.set_global_policy("mixed_float16")` runs computations in float16, keeps weights in float32 for numerical stability. 2-3x throughput improvement on Tensor Core GPUs. Do not use on CPU-only machines — float16 is not accelerated.

## Quick Start

```bash
pip install tensorflow tensorflow-datasets
```

```python
import tensorflow as tf
AUTO = tf.data.AUTOTUNE
dataset = (dataset
           .map(parse_fn, num_parallel_calls=AUTO)
           .shuffle(10_000)
           .batch(64)
           .prefetch(AUTO))
```
