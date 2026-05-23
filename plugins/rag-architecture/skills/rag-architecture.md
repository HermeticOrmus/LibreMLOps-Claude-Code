# RAG architecture pattern library

## The 7 layers

1. **Ingestion** — source → parsed text
2. **Chunking** — text → retrievable units
3. **Embedding** — chunks → vectors
4. **Storage** — vectors + metadata
5. **Retrieval** — query → relevant chunks
6. **Generation** — chunks + query → answer
7. **Evaluation** — measure continuously

## Chunking decision tree

```
Content type:
  Code → AST-based chunking (function/class boundaries)
  Markdown → header-based (## sections)
  PDF (layout-rich) → Unstructured/Marker; layout-aware splits
  Plain text → semantic (sentence-aware, ~512 tokens, 10% overlap)
  Conversation logs → message-pair boundaries
  Tabular → row or row-group based
```

Long documents (> 10k tokens): hierarchical chunking. Retrieve child chunks; generate from parent context.

## Hybrid retrieval

```python
def hybrid_retrieve(query, k=20):
    dense = vector_db.search(embed(query), k=k)
    sparse = bm25_index.search(query, k=k)
    return reciprocal_rank_fusion([dense, sparse])
```

RRF formula: score(doc) = sum(1 / (rank_i + 60)) across retrieval methods.

## Reranking

Top-K → reranker → final K':
- Cross-encoder (ms-marco-MiniLM-L-6-v2 or similar): ~50ms for 50 candidates, self-hostable
- Cohere rerank-3: API call, fast, high quality
- ColBERT: late-interaction; high quality, complex deployment
- LLM-as-reranker: highest quality, highest cost; reserve for top 10-20

## Generation prompting

```
Documents:
[doc_1] {chunk_1.text}
[doc_2] {chunk_2.text}
[doc_3] {chunk_3.text}

Question: {query}

Rules:
- Cite each fact with [doc_id]
- If insufficient information: respond "I don't have enough information to answer that."
- Don't add information not in documents.
- Note ambiguity if multiple interpretations.

Answer:
```

## Evaluation metrics

### Retrieval

| Metric | Formula | Target |
|---|---|---|
| Recall@k | (relevant docs in top-k) / (total relevant) | > 0.8 @ k=5 |
| Precision@k | relevant in top-k / k | > 0.6 @ k=5 |
| MRR | mean(1 / rank of first relevant) | > 0.7 |
| NDCG@k | rank-weighted, accounts for partial relevance | > 0.8 |

### Generation

| Metric | What it measures |
|---|---|
| Faithfulness | % claims supported by retrieved chunks (LLM-judge) |
| Answer relevance | Does answer address the query (LLM-judge) |
| Citation accuracy | Do cited doc IDs match the chunks actually used |
| Latency p95 | End-to-end response time |

## Common mistakes catalog

### Hallucinations in production

Causes:
- No refusal instruction → model fills gap with plausible text
- Retrieval returns irrelevant chunks → model uses them anyway
- Chunks span context limit → some context dropped silently
- Generation model too weak to follow citation rule

Fix: stricter prompt, better retrieval, citation enforcement at parse-time.

### "Demo works, production fails"

Often: corpus changed between demo and prod. Re-embed. Check eval on prod corpus, not demo corpus.

### Pure dense retrieval misses exact terms

Hybrid (dense + BM25) catches both. Pure dense fails on rare technical terms, names, codes.

### Retrieval is too slow

- Vector DB index needs tuning (HNSW parameters)
- Query embedding latency adds up (cache common queries)
- Reranking too many candidates (cap at 50-100)

### Reranker is too slow

Switch from cross-encoder to bi-encoder for first-pass, cross-encoder only for top 20.

### Hallucinations when out-of-corpus

The model needs the refusal prompt explicitly. Without it, models almost always answer rather than say "I don't know."

## Vector DB performance reference

| Operation | pgvector | Pinecone | Qdrant |
|---|---|---|---|
| Insert 1M vectors | ~10 min | ~5 min | ~3 min |
| Query (k=10) on 1M | ~50ms | ~30ms | ~25ms |
| Query (k=10) on 100M | ~500ms | ~100ms | ~80ms |
| Update vector | atomic | atomic | atomic |
| Hybrid filter + search | yes (SQL) | yes (filter) | yes (payload filter) |

Numbers approximate; depend on dimensionality + hardware.

## Cross-references

- `model-evaluation` plugin — broader eval methodology
- `prompt-engineering` plugin — generation prompt design
- `vector-databases` plugin — DB selection + ops
- `data-pipelines` plugin — ingestion + re-indexing automation
