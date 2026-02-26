# /vectordb

Create vector stores, upsert embeddings, query with filters, and reindex after embedding model changes.

## Trigger

`/vectordb [action] [options]`

## Actions

- `create` - Initialize vector store (pgvector, Pinecone, Qdrant) with HNSW index
- `upsert` - Embed and insert documents in batches with metadata
- `query` - Search by vector similarity with metadata filters and tenant isolation
- `reindex` - Plan and execute reindexing after embedding model change

## Examples

### create — pgvector with HNSW index

```sql
-- Create extension and table
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE documents (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    content     TEXT NOT NULL,
    embedding   vector(1536),
    tenant_id   TEXT NOT NULL,
    source      TEXT,
    model_ver   TEXT DEFAULT 'text-embedding-3-large-v1',
    created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- HNSW index for recall (higher m = better recall, more memory)
CREATE INDEX ON documents USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- Filter index for tenant queries
CREATE INDEX ON documents (tenant_id);

-- Set ef_search at query time for recall/latency tradeoff
-- SET hnsw.ef_search = 100;  -- higher = better recall, slower
```

### upsert — Batch embed and insert to Pinecone

```python
from pinecone import Pinecone, ServerlessSpec
from openai import OpenAI
import uuid

pc = Pinecone(api_key="PINECONE_API_KEY")
oai = OpenAI()

index = pc.Index("documents")

def upsert_batch(docs: list[dict], tenant_id: str, batch_size: int = 100):
    for i in range(0, len(docs), batch_size):
        batch = docs[i:i+batch_size]
        texts = [d["content"] for d in batch]
        embeddings = oai.embeddings.create(
            input=texts, model="text-embedding-3-large", dimensions=1536
        ).data

        vectors = [{
            "id": d.get("id", str(uuid.uuid4())),
            "values": emb.embedding,
            "metadata": {"content": d["content"][:1000],
                         "source": d.get("source", ""),
                         "model_ver": "text-embedding-3-large-v1"},
        } for d, emb in zip(batch, embeddings)]

        index.upsert(vectors=vectors, namespace=tenant_id)
        print(f"Upserted {min(i+batch_size, len(docs))}/{len(docs)}")
```

### query — Similarity search with tenant isolation

```python
# pgvector query with ef_search and tenant filter
def search_pgvector(conn, query: str, tenant_id: str, k: int = 10):
    from openai import OpenAI
    emb = OpenAI().embeddings.create(
        input=query, model="text-embedding-3-large", dimensions=1536
    ).data[0].embedding

    with conn.cursor() as cur:
        cur.execute("SET hnsw.ef_search = 100")
        cur.execute("""
            SELECT id, content, source,
                   1 - (embedding <=> %s::vector) AS similarity
            FROM documents
            WHERE tenant_id = %s
            ORDER BY embedding <=> %s::vector
            LIMIT %s
        """, (emb, tenant_id, emb, k))
        return [{"id": r[0], "content": r[1],
                 "source": r[2], "similarity": r[3]}
                for r in cur.fetchall()]

results = search_pgvector(conn, "What is the refund policy?",
                          tenant_id="org_123", k=5)
for r in results:
    print(f"[{r['similarity']:.3f}] {r['content'][:100]}")
```

### reindex — Plan and execute after model change

```python
import psycopg2
from openai import OpenAI

def reindex_collection(conn, new_model: str = "text-embedding-3-large",
                        new_dim: int = 1536, batch_size: int = 100):
    """Re-embed all documents with new model. Atomic swap via temporary column."""
    oai = OpenAI()

    with conn.cursor() as cur:
        # Add new column for new embeddings
        cur.execute(f"ALTER TABLE documents ADD COLUMN IF NOT EXISTS embedding_new vector({new_dim})")
        conn.commit()

        # Fetch all documents
        cur.execute("SELECT id, content FROM documents WHERE embedding_new IS NULL")
        rows = cur.fetchall()

    print(f"Reindexing {len(rows)} documents with {new_model}...")

    for i in range(0, len(rows), batch_size):
        batch = rows[i:i+batch_size]
        ids = [r[0] for r in batch]
        texts = [r[1] for r in batch]
        embeddings = oai.embeddings.create(input=texts, model=new_model,
                                            dimensions=new_dim).data

        with conn.cursor() as cur:
            for doc_id, emb in zip(ids, embeddings):
                cur.execute("UPDATE documents SET embedding_new = %s WHERE id = %s",
                            (emb.embedding, doc_id))
        conn.commit()
        print(f"  {min(i+batch_size, len(rows))}/{len(rows)}")

    # Atomic column swap
    with conn.cursor() as cur:
        cur.execute("ALTER TABLE documents RENAME COLUMN embedding TO embedding_old")
        cur.execute("ALTER TABLE documents RENAME COLUMN embedding_new TO embedding")
        cur.execute("DROP INDEX IF EXISTS idx_docs_embedding_hnsw")
        cur.execute("""
            CREATE INDEX idx_docs_embedding_hnsw ON documents
            USING hnsw (embedding vector_cosine_ops)
            WITH (m = 16, ef_construction = 64)
        """)
        cur.execute("ALTER TABLE documents DROP COLUMN embedding_old")
    conn.commit()
    print("Reindex complete")
```

## Options

- `--db <type>` - Vector database: pgvector, pinecone, qdrant, weaviate, chroma
- `--dimension <n>` - Embedding dimension (default: 1536)
- `--metric <metric>` - Similarity metric: cosine, dot, euclidean (default: cosine)
- `--hnsw-m <n>` - HNSW M parameter (default: 16)
- `--hnsw-ef <n>` - HNSW ef_construction (default: 64)
- `--ef-search <n>` - HNSW ef_search at query time (default: 100)
- `--nlist <n>` - IVF number of clusters (default: sqrt(n_vectors))
- `--nprobe <n>` - IVF cells to search (default: 10)
- `--namespace <str>` - Tenant namespace for Pinecone isolation
- `--batch-size <n>` - Upsert batch size (default: 100)
- `--k <n>` - Number of nearest neighbors to return (default: 10)
