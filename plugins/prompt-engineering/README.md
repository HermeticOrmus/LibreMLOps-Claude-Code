# prompt-engineering

Chain-of-thought, few-shot design, ReAct agents, structured output with Pydantic+instructor, prompt injection defense, DSPy optimization, and Git-tracked prompt versioning.

## What This Plugin Does

Covers systematic prompt engineering from baseline through production: zero-shot vs few-shot selection, chain-of-thought (Wei et al. 2022) with XML-delimited reasoning, ReAct (Yao et al. 2022) tool-use agents, structured output enforcement with instructor + Pydantic models, prompt injection sanitization and role isolation, DSPy BootstrapFewShot for automated few-shot selection, and a YAML-based prompt registry for versioning and A/B testing.

## When to Use

- Building a CoT prompt for multi-step reasoning tasks (math, clinical coding, legal analysis)
- Enforcing Pydantic schema on LLM outputs with instructor retry on validation failure
- Designing a ReAct agent that interleaves reasoning and tool calls
- Defending against prompt injection from untrusted user input
- Running DSPy to automatically find better few-shot demonstrations instead of manual iteration
- Versioning prompts in Git-tracked YAML files with evaluation results and changelog
- Evaluating a prompt change against a labeled test set before deploying

## Components

| Component | Description |
|-----------|-------------|
| `agents/prompt-engineer` | Expert in CoT, few-shot, ReAct, DSPy, injection defense, structured output |
| `skills/prompt-engineering-patterns` | CoT few-shot, instructor+Pydantic, ReAct agent, injection sanitization, DSPy optimization |
| `commands/prompt-eng` | `/prompt-eng design\|test\|optimize\|version` workflows |

## Key Concepts

**Chain-of-Thought**
Wei et al. (2022) showed that prompting with "Let's think step by step" or providing reasoning examples improves accuracy by 40-60% on multi-step tasks. CoT works by forcing intermediate computation before the final answer. The model cannot shortcut to a wrong answer if it must show its work.

**Structured Output**
LLM outputs are strings. Systems that parse them with regex break on minor formatting changes. Use instructor with Pydantic models: define the schema, get typed objects back, let the library handle retry on validation failure. Your application code never touches raw LLM strings.

**Prompt Injection**
User-controlled text interpolated into prompts is an attack surface. An attacker can include "Ignore all previous instructions" in a document and redirect model behavior. Sanitize inputs, put untrusted content in user turns (not system), and wrap in explicit delimiters.

**DSPy Over Manual Iteration**
Manually trying different few-shot examples is biased by what the developer finds intuitive. DSPy BootstrapFewShot searches over candidate demonstrations using a labeled validation metric. It finds examples that actually improve measured performance, not examples that look reasonable.

## Quick Start

```bash
pip install anthropic instructor dspy-ai pydantic
```

```python
import instructor
from anthropic import Anthropic
from pydantic import BaseModel

client = instructor.from_anthropic(Anthropic())

class Sentiment(BaseModel):
    label: str
    confidence: float

result = client.messages.create(
    model="claude-opus-4-6", max_tokens=128,
    messages=[{"role": "user", "content": "Classify: 'I love this product'"}],
    response_model=Sentiment,
)
print(result.label, result.confidence)
```
