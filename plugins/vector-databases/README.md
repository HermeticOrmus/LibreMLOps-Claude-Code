# vector-databases

HNSW/IVF-PQ index configuration, pgvector, Pinecone, Qdrant, Weaviate, and FAISS with tenant namespace isolation, metadata filtering, embedding drift detection, and reindexing pipelines.

## What This Plugin Does

Covers production vector storage: HNSW parameter tuning (M, ef_construction, ef_search) for recall targets, IVF-PQ for billion-scale compressed indexing, pgvector with ivfflat and hnsw index types and SQL-integrated queries, Pinecone serverless with namespace isolation per tenant, Qdrant with named vectors and scalar quantization, FAISS for offline batch indexing with recall benchmarking, embedding drift detection with KS test and centroid similarity, and atomic reindexing pipelines for embedding model migration.

## When to Use

- Setting up pgvector with HNSW index and correct M/ef_construction parameters
- Implementing per-tenant namespace isolation in Pinecone or Weaviate multi-tenancy
- Configuring Qdrant scalar quantization to reduce memory by 4x with minimal recall loss
- Benchmarking HNSW recall@10 against brute-force flat index before production
- Detecting that an embedding model update has caused distribution drift in stored vectors
- Planning and executing a zero-downtime reindex (add new column → fill → atomic swap)
- Choosing between FAISS IVF-PQ (compressed, offline) and HNSW (in-memory, high recall)

## Components

| Component | Description |
|-----------|-------------|
| `agents/vectordb-engineer` | Expert in HNSW/IVF, pgvector, Pinecone, Qdrant, FAISS, drift, reindexing |
| `skills/vectordb-patterns` | pgvector HNSW setup, Pinecone namespace upsert, Qdrant named vectors, FAISS, drift detection |
| `commands/vectordb` | `/vectordb create\|upsert\|query\|reindex` workflows |

## Key Concepts

**HNSW vs IVF-PQ**
HNSW: graph-based, high recall (> 98%), memory-intensive (~50 bytes per vector at M=16), no training step. Best for < 10M vectors where recall matters. IVF-PQ: cluster-based with product quantization, 32x compression, 90-95% recall, requires training on representative sample. Best for > 10M vectors with memory constraints.

**ef_search Is a Query-Time Parameter**
HNSW ef_search controls the search width at query time — it can be tuned per query without rebuilding the index. Low ef_search: faster, lower recall. High ef_search: slower, higher recall. Set conservatively for latency-sensitive queries, higher for offline batch queries.

**Namespace Isolation Is Hard Isolation**
Pinecone namespaces and Weaviate tenants provide storage-level isolation — tenant A cannot accidentally see tenant B's vectors regardless of query construction bugs. Metadata-only filtering (WHERE tenant_id = ?) is soft isolation and is a data leakage risk on any query construction bug.

**Always Store Embedding Model Version as Metadata**
When you upgrade your embedding model, stored vectors from the old model are incompatible with queries from the new model. Without `model_version` metadata, you cannot identify which vectors need reindexing. Store `model_ver` on every vector; reindex only vectors with outdated versions.

## Quick Start

```bash
pip install pgvector psycopg2-binary pinecone-client qdrant-client faiss-cpu openai
```

```sql
-- pgvector
CREATE EXTENSION vector;
CREATE TABLE docs (id SERIAL, embedding vector(1536));
CREATE INDEX ON docs USING hnsw (embedding vector_cosine_ops) WITH (m=16, ef_construction=64);
```
