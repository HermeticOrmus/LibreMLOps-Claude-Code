# /deploy-model

Package, serve, scale, and roll out ML models with Triton, FastAPI, ONNX, and Kubernetes.

## Trigger

`/deploy-model [action] [options]`

## Actions

- `package` - Export model (ONNX/TorchScript) and build Docker image
- `serve` - Generate FastAPI or Triton serving configuration
- `scale` - Configure dynamic batching, concurrency, and resource allocation
- `rollout` - Canary deployment configuration and traffic splitting

## Examples

### package — Export and containerize

```bash
# 1. Export PyTorch to ONNX
python -c "
import torch, onnxruntime as ort, numpy as np

model = torch.load('model.pt').eval()
dummy = torch.randn(1, 512)

torch.onnx.export(
    model, dummy, 'model.onnx',
    opset_version=17,
    input_names=['input'],
    output_names=['output'],
    dynamic_axes={'input': {0: 'batch'}, 'output': {0: 'batch'}}
)

# Validate
session = ort.InferenceSession('model.onnx', providers=['CPUExecutionProvider'])
ort_out = session.run(None, {'input': dummy.numpy()})[0]
torch_out = model(dummy).detach().numpy()
max_diff = np.abs(ort_out - torch_out).max()
print(f'Max diff: {max_diff:.2e} (should be < 1e-4)')
"

# 2. Optimize with onnxsim
pip install onnxsim
onnxsim model.onnx model_opt.onnx

# 3. Build serving Docker image
cat > Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt . && pip install --no-cache-dir -r requirements.txt
COPY app/ app/ && COPY model_opt.onnx models/model.onnx
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

docker build -t sentiment-model:1.3.0 .
docker run -p 8000:8000 sentiment-model:1.3.0
```

### serve — FastAPI with ONNX Runtime

```python
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import onnxruntime as ort
import numpy as np
import time

model_state = {}

@asynccontextmanager
async def lifespan(app: FastAPI):
    model_state["session"] = ort.InferenceSession(
        "models/model.onnx",
        providers=["CUDAExecutionProvider", "CPUExecutionProvider"]
    )
    model_state["input_name"] = model_state["session"].get_inputs()[0].name
    model_state["ready"] = True
    yield

app = FastAPI(lifespan=lifespan)

class PredictRequest(BaseModel):
    features: list[float]

@app.post("/predict")
async def predict(req: PredictRequest):
    t0 = time.perf_counter()
    X = np.array(req.features, dtype=np.float32).reshape(1, -1)
    output = model_state["session"].run(
        None, {model_state["input_name"]: X}
    )[0]
    return {
        "prediction": int(np.argmax(output[0])),
        "probabilities": output[0].tolist(),
        "latency_ms": round((time.perf_counter() - t0) * 1000, 2)
    }

@app.get("/health")
def health(): return {"status": "healthy"}

@app.get("/ready")
def ready():
    if not model_state.get("ready"):
        raise HTTPException(503, "Not ready")
    return {"status": "ready"}
```

### scale — Kubernetes deployment with resource limits

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sentiment-model
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sentiment-model
      version: "1.3.0"
  template:
    spec:
      containers:
        - name: model-server
          image: my-registry/sentiment-model:1.3.0
          ports:
            - containerPort: 8000
          resources:
            requests:
              cpu: "500m"
              memory: "1Gi"
            limits:
              cpu: "2"
              memory: "4Gi"
          readinessProbe:
            httpGet:
              path: /ready
              port: 8000
            initialDelaySeconds: 30
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 5
            periodSeconds: 15
          env:
            - name: MODEL_VERSION
              value: "1.3.0"
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: sentiment-model-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: sentiment-model
  minReplicas: 2
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
```

### rollout — Canary with Istio

```bash
# Deploy canary (v2) alongside stable (v1)
kubectl apply -f k8s/deployment-v2.yaml

# Start canary: 10% traffic to v2
kubectl apply -f - << 'EOF'
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: sentiment-model-vs
spec:
  hosts: [sentiment-model]
  http:
    - route:
        - destination:
            host: sentiment-model
            subset: v1
          weight: 90
        - destination:
            host: sentiment-model
            subset: v2
          weight: 10
EOF

# Monitor canary metrics (error rate, latency)
# If healthy after 30 min, promote:
# weight: v1=0, v2=100

# Automated rollback: if v2 error rate > 1%
kubectl set image deployment/sentiment-model-v2 model-server=my-registry/sentiment-model:v1.2.3
```

## Options

- `--model-path <path>` - Path to model artifact for packaging
- `--framework <pytorch|sklearn|onnx>` - Model framework
- `--serving <fastapi|triton|torchserve|bentoml>` - Serving framework
- `--replicas <n>` - Number of Kubernetes replicas
- `--canary-pct <n>` - Canary traffic percentage (0-100)
- `--gpu` - Enable GPU inference configuration
- `--batch-size <n>` - Max batch size for dynamic batching
