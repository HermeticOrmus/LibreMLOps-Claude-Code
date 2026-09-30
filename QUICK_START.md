# Quick start

Twenty minutes from clone to designing your first RAG system.

Inside Claude Code:

```
/plugin marketplace add HermeticOrmus/LibreMLOps-Claude-Code
/plugin install rag-architecture@libre-mlops
```

Or from a clone, installing every plugin through the Claude Code CLI:

```bash
git clone https://github.com/HermeticOrmus/LibreMLOps-Claude-Code.git ~/projects/LibreMLOps-Claude-Code
cd ~/projects/LibreMLOps-Claude-Code
./setup.sh
```

### Install in Grok Build

Grok Build reads the same plugin folders. Add the marketplace and install a plugin, or install one plugin straight from its folder:

```bash
grok plugin marketplace add HermeticOrmus/LibreMLOps-Claude-Code
grok plugin install rag-architecture@LibreMLOps-Claude-Code --trust
# or, without the marketplace:
grok plugin install HermeticOrmus/LibreMLOps-Claude-Code#plugins/rag-architecture --trust
```

From a clone, `./setup.sh --grok` installs every plugin through the `grok` CLI. Start a new Grok session to load them. The `libre-mlops-hooks` plugin uses a hook format Grok supports, but it has not been verified in a live Grok session.

### First prompt

Restart Claude Code, then try:

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

`/rag` also runs single actions: `/rag build` to ingest and index documents, `/rag query` for hybrid search with re-ranking, `/rag evaluate` for RAGAS metrics, and `/rag optimize` to turn low scores into fixes.
