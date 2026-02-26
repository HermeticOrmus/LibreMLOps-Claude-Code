# /tensorflow

Build Keras models, optimize tf.data pipelines, export SavedModel, and quantize for TFLite deployment.

## Trigger

`/tensorflow [action] [options]`

## Actions

- `build` - Create Keras model with functional or subclassing API
- `optimize` - Fix tf.data pipeline order and add AUTOTUNE
- `export` - Save as SavedModel with serving signatures
- `serve` - Convert to TFLite with PTQ or QAT quantization

## Examples

### build — Functional API model with compilation

```python
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

# Input layers
inputs = keras.Input(shape=(128,), name="features")
x = layers.BatchNormalization()(inputs)
x = layers.Dense(256, activation="relu")(x)
x = layers.Dropout(0.3)(x)
x = layers.Dense(128, activation="relu")(x)
x = layers.Dropout(0.2)(x)
outputs = layers.Dense(1, activation="sigmoid", name="output")(x)

model = keras.Model(inputs=inputs, outputs=outputs, name="classifier")

model.compile(
    optimizer=keras.optimizers.AdamW(learning_rate=3e-4, weight_decay=1e-4),
    loss="binary_crossentropy",
    metrics=["accuracy", keras.metrics.AUC(name="auc"),
             keras.metrics.Precision(name="precision"),
             keras.metrics.Recall(name="recall")],
)

# Callbacks
callbacks = [
    keras.callbacks.EarlyStopping(monitor="val_auc", mode="max",
                                    patience=10, restore_best_weights=True),
    keras.callbacks.ModelCheckpoint("best_model.keras", monitor="val_auc",
                                     mode="max", save_best_only=True),
    keras.callbacks.ReduceLROnPlateau(monitor="val_loss", patience=5,
                                       factor=0.5, min_lr=1e-6),
]

model.fit(train_ds, validation_data=val_ds, epochs=100, callbacks=callbacks)
```

### optimize — tf.data pipeline with correct order

```python
import tensorflow as tf

AUTO = tf.data.AUTOTUNE

def build_pipeline(dataset: tf.data.Dataset, batch_size: int,
                   training: bool) -> tf.data.Dataset:
    # 1. Parse/preprocess in parallel
    dataset = dataset.map(parse_and_preprocess, num_parallel_calls=AUTO)

    # 2. Cache after expensive ops (if fits in memory)
    # dataset = dataset.cache()

    # 3. Shuffle only for training
    if training:
        dataset = dataset.shuffle(buffer_size=10_000, reshuffle_each_iteration=True)

    # 4. Batch
    dataset = dataset.batch(batch_size, drop_remainder=training)

    # 5. Prefetch ALWAYS last
    dataset = dataset.prefetch(AUTO)

    return dataset

# Profile: check input pipeline
options = tf.data.Options()
options.experimental_optimization.autotune = True
options.experimental_optimization.map_and_batch_fusion = True
train_ds = build_pipeline(raw_dataset, 64, training=True).with_options(options)
```

### export — SavedModel with serving signature

```python
import tensorflow as tf

@tf.function(input_signature=[
    tf.TensorSpec(shape=[None, 128], dtype=tf.float32, name="features")
])
def serve(features):
    proba = model(features, training=False)
    return {
        "probabilities": proba,
        "predicted_class": tf.cast(proba > 0.5, tf.int32),
    }

tf.saved_model.save(
    model, "saved_models/classifier/1",
    signatures={"serving_default": serve}
)

# Verify
loaded = tf.saved_model.load("saved_models/classifier/1")
infer = loaded.signatures["serving_default"]
result = infer(features=tf.random.normal([4, 128]))
print(result["probabilities"])

# TF Serving command:
# docker run -p 8501:8501 -v $(pwd)/saved_models:/models tensorflow/serving \
#   --model_name=classifier --model_base_path=/models/classifier
```

### serve — TFLite quantization

```python
import tensorflow as tf
import numpy as np

# PTQ: float16 (fast, minimal accuracy loss)
converter = tf.lite.TFLiteConverter.from_saved_model("saved_models/classifier/1")
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
tflite_model = converter.convert()

with open("model_f16.tflite", "wb") as f:
    f.write(tflite_model)

print(f"Size: {len(tflite_model)/1e6:.2f}MB")

# Benchmark
interpreter = tf.lite.Interpreter(model_content=tflite_model)
interpreter.allocate_tensors()
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

interpreter.set_tensor(input_details[0]["index"],
                       np.random.randn(1, 128).astype(np.float32))
interpreter.invoke()
output = interpreter.get_tensor(output_details[0]["index"])
print("TFLite output:", output)
```

## Options

- `--model-type <type>` - Model API: functional, subclass (default: functional)
- `--input-shape <shape>` - Input tensor shape (e.g., "128" or "224,224,3")
- `--hidden-units <units>` - Comma-separated hidden layer sizes
- `--dropout <float>` - Dropout rate (default: 0.3)
- `--batch-size <n>` - Training batch size (default: 64)
- `--export-path <path>` - SavedModel output directory
- `--quantization <type>` - TFLite quantization: float16, int8, qat
- `--calibration-samples <n>` - Samples for int8 PTQ calibration (default: 500)
