# model-deployment

Model serving with BentoML, TorchServe, Triton Inference Server, FastAPI, ONNX export, and Kubernetes deployment.

## What This Plugin Does

Covers the full model deployment lifecycle: ONNX export and validation, FastAPI production serving (model-at-startup, health checks, Prometheus metrics), Triton model repository layout and config.pbtxt, dynamic batching configuration, containerization with Docker, Kubernetes deployment with HPA and resource limits, and canary traffic splitting with Istio.

## When to Use

- Exporting a PyTorch model to ONNX for optimized serving
- Building a FastAPI ML serving endpoint with proper health checks
- Configuring Triton Inference Server for multi-model GPU serving
- Setting up dynamic batching to balance latency and throughput
- Writing Kubernetes deployment YAML with readiness/liveness probes
- Implementing canary deployment with Istio traffic weights
- Load testing a serving endpoint with locust before production traffic

## Components

| Component | Description |
|-----------|-------------|
| `agents/ml-deploy-engineer` | Expert in BentoML, TorchServe, Triton, FastAPI, ONNX, KServe, Istio |
| `skills/model-deployment-patterns` | Code patterns: FastAPI serving, Triton config, ONNX export, canary, load testing |
| `commands/deploy-model` | `/deploy-model package\|serve\|scale\|rollout` workflows |

## Key Concepts

**Latency vs Throughput**
Single request latency (p99) vs requests per second are inversely related for fixed resources. Dynamic batching improves throughput at cost of individual request latency. Set `max_queue_delay_microseconds` to cap the latency penalty.

**ONNX for Production**
PyTorch eager mode has Python interpreter overhead. ONNX Runtime eliminates it: 2–3x speedup typical. Export with `dynamic_axes` for variable batch sizes. Always validate numerical equivalence after export.

**Health vs Readiness**
`/health` = is the process alive (liveness probe). `/ready` = is the model loaded and ready to serve (readiness probe). Never merge them. Kubernetes kills pods that fail liveness, and stops routing to pods that fail readiness.

**Canary Pattern**
Route 10% of traffic to new model version. Monitor error rate and latency for 30 minutes. If stable, increase to 50%, then 100%. Istio VirtualService weights control the split. Automated rollback if error rate exceeds threshold.

## Quick Start

```bash
pip install fastapi uvicorn onnxruntime tritonclient locust
```

```python
# Minimal FastAPI serving
from fastapi import FastAPI
app = FastAPI()

@app.get("/health")
def health(): return {"status": "healthy"}

@app.post("/predict")
async def predict(request: dict): return model.predict(request["features"])
```
