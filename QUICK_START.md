# Quick start

Twenty minutes from clone to designing your first RAG system.

```bash
git clone https://github.com/HermeticOrmus/LibreMLOps-Claude-Code.git ~/projects/LibreMLOps-Claude-Code
cd ~/projects/LibreMLOps-Claude-Code
./setup.sh
```

```
/rag design a RAG system for customer support over a 10k-article knowledge base. Multilingual (EN, ES, PT). Customer queries are short and ambiguous. Quality bar: customer-facing.
```

Expected output:
- Per-layer design with reasoning
- Eval harness structure (50+ golden examples)
- Multilingual considerations (BGE-M3 or E5-multilingual embedding)
- Hybrid retrieval + reranker recommendation
- Generation prompt with citation + refusal
- Failure modes to expect

If the response doesn't mention eval harness or hybrid retrieval, plugin install didn't take.
