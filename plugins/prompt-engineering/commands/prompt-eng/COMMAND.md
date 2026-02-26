# /prompt-eng

Design, test, optimize, and version prompts for production LLM applications.

## Trigger

`/prompt-eng [action] [options]`

## Actions

- `design` - Build a prompt using appropriate technique (zero-shot, CoT, few-shot, ReAct)
- `test` - Evaluate prompt against labeled examples with metrics
- `optimize` - Use DSPy BootstrapFewShot to automatically find better few-shot examples
- `version` - Register prompt with evaluation results to YAML prompt registry

## Examples

### design — Chain-of-Thought prompt

```python
SYSTEM_PROMPT = """You are a contract risk analyst. You review contract clauses for legal risk.

For each clause, reason through:
1. What obligation does this create?
2. What is the financial/legal exposure?
3. Is this standard or unusual?
Then give a risk rating.

Format:
<reasoning>[step by step analysis]</reasoning>
<risk_level>LOW|MEDIUM|HIGH|CRITICAL</risk_level>
<explanation>[one sentence summary]</explanation>"""

# Test on a clause
clause = "The Client shall indemnify and hold harmless the Vendor from any and all claims..."

from anthropic import Anthropic
client = Anthropic()
response = client.messages.create(
    model="claude-opus-4-6",
    max_tokens=512,
    system=SYSTEM_PROMPT,
    messages=[{"role": "user", "content": f"Clause: {clause}"}]
)
print(response.content[0].text)
```

### test — Evaluate prompt against labeled set

```python
import json
from pathlib import Path

def evaluate_prompt(prompt_fn, test_cases: list[dict], metric_fn) -> dict:
    """
    prompt_fn: function(input_str) -> str output
    test_cases: [{"input": ..., "expected": ...}]
    metric_fn: function(expected, actual) -> float
    """
    scores = []
    failures = []
    for case in test_cases:
        actual = prompt_fn(case["input"])
        score = metric_fn(case["expected"], actual)
        scores.append(score)
        if score < 0.5:
            failures.append({"input": case["input"],
                             "expected": case["expected"],
                             "actual": actual})

    result = {
        "n": len(scores),
        "accuracy": sum(s >= 0.5 for s in scores) / len(scores),
        "mean_score": sum(scores) / len(scores),
        "failures": failures[:5],  # first 5 failures for review
    }
    print(f"Accuracy: {result['accuracy']:.1%} | Mean score: {result['mean_score']:.3f}")
    return result

# Example metric: exact match for classification
exact_match = lambda expected, actual: float(expected.lower() in actual.lower())
```

### optimize — DSPy automatic few-shot selection

```python
import dspy
from dspy.teleprompt import BootstrapFewShot

dspy.configure(lm=dspy.LM("anthropic/claude-opus-4-6"))

class ContractRisk(dspy.Signature):
    """Classify contract clause risk level."""
    clause: str = dspy.InputField()
    risk_level: str = dspy.OutputField(desc="LOW, MEDIUM, HIGH, or CRITICAL")

class RiskClassifier(dspy.Module):
    def __init__(self):
        self.predict = dspy.ChainOfThought(ContractRisk)

    def forward(self, clause: str):
        return self.predict(clause=clause)

metric = lambda ex, pred, trace=None: ex.risk_level == pred.risk_level

# Optimize: automatically selects best few-shot demonstrations
optimizer = BootstrapFewShot(metric=metric, max_bootstrapped_demos=6)
optimized = optimizer.compile(RiskClassifier(), trainset=train_examples)
optimized.save("contract_risk_v2.json")
```

### version — Register prompt to YAML registry

```yaml
# prompts/contract-risk-v2.yaml
id: contract-risk-v2
version: "2.0.0"
task: contract_risk_classification
model: claude-opus-4-6
temperature: 0.0
max_tokens: 512
technique: chain-of-thought + few-shot
system_prompt: |
  You are a contract risk analyst...
  [full prompt text]
evaluation:
  dataset: contract-clauses-test-v3
  n_examples: 120
  accuracy: 0.891
  created_at: "2024-03-15T10:30:00Z"
  evaluator: exact_match
changelog:
  - "v2.0.0: Added CoT reasoning; +8.3pp accuracy vs v1"
  - "v1.0.0: Initial zero-shot baseline"
```

```python
# Load and use versioned prompt
import yaml

def load_prompt(prompt_id: str) -> dict:
    with open(f"prompts/{prompt_id}.yaml") as f:
        return yaml.safe_load(f)

prompt_config = load_prompt("contract-risk-v2")
# Use in API call with prompt_config["system_prompt"], etc.
```

## Options

- `--technique <type>` - Technique: zero-shot, few-shot, cot, react, dspy
- `--model <model>` - LLM model identifier (default: claude-opus-4-6)
- `--temperature <float>` - Sampling temperature (default: 0.0 for extraction)
- `--n-examples <n>` - Number of few-shot examples to include
- `--test-data <path>` - Path to labeled JSONL test set for evaluation
- `--metric <type>` - Evaluation metric: exact_match, contains, llm_judge
- `--output <path>` - Path for versioned prompt YAML output
