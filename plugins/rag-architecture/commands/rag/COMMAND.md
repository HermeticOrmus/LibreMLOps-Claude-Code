# /rag

Build, query, evaluate, and optimize RAG pipelines with chunking, embedding, hybrid search, and re-ranking.

## Trigger

`/rag [action] [options]`

## Actions

- `build` - Ingest documents, chunk, embed, and index to vector store
- `query` - Execute hybrid search + re-rank retrieval on a question
- `evaluate` - Run RAGAS evaluation on labeled question/answer set
- `optimize` - Diagnose low RAGAS scores and tune chunking, retrieval, or re-ranking

## Examples

### build — Ingest and index documents

```python
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.document_loaders import PyPDFLoader
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import PGVector
import os

# Load and chunk
loader = PyPDFLoader("data/contracts/msa.pdf")
docs = loader.load()

splitter = RecursiveCharacterTextSplitter(
    chunk_size=512, chunk_overlap=64,
    separators=["\n\n", "\n", ". ", " ", ""]
)
chunks = splitter.split_documents(docs)

# Embed and store
embeddings = OpenAIEmbeddings(model="text-embedding-3-large", dimensions=1536)
vectorstore = PGVector.from_documents(
    documents=chunks,
    embedding=embeddings,
    collection_name="contracts",
    connection_string=os.getenv("POSTGRES_CONNECTION_STRING"),
)
print(f"Indexed {len(chunks)} chunks")
```

### query — Hybrid search with re-ranking

```python
from langchain.retrievers import BM25Retriever, EnsembleRetriever
from sentence_transformers import CrossEncoder

# Two-stage retrieval
bm25 = BM25Retriever.from_documents(chunks); bm25.k = 20
dense = vectorstore.as_retriever(search_kwargs={"k": 20})
hybrid = EnsembleRetriever(retrievers=[bm25, dense], weights=[0.4, 0.6])

cross_encoder = CrossEncoder("cross-encoder/ms-marco-MiniLM-L-6-v2")

def query_rag(question: str, top_n: int = 5) -> list:
    candidates = hybrid.get_relevant_documents(question)
    pairs = [(question, doc.page_content) for doc in candidates]
    scores = cross_encoder.predict(pairs)
    ranked = sorted(zip(scores, candidates), key=lambda x: x[0], reverse=True)
    return [doc for _, doc in ranked[:top_n]]

results = query_rag("What is the liability cap in the contract?")
for r in results:
    print(f"[score={r.metadata.get('rerank_score', 'N/A')}] {r.page_content[:200]}")
```

### evaluate — RAGAS metrics

```python
from ragas import evaluate as ragas_evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_recall, context_precision
from datasets import Dataset

# Build test dataset (50+ questions for meaningful evaluation)
rows = []
for question, ground_truth in zip(test_questions, test_ground_truths):
    answer, contexts = run_rag_pipeline(question)
    rows.append({
        "question": question,
        "answer": answer,
        "contexts": contexts,   # list of retrieved strings
        "ground_truth": ground_truth,
    })

dataset = Dataset.from_list(rows)
scores = ragas_evaluate(dataset,
                        metrics=[faithfulness, answer_relevancy,
                                 context_recall, context_precision])
df = scores.to_pandas()
print(df.mean())

# Targets:
# faithfulness      > 0.85  (low = hallucination)
# context_recall    > 0.80  (low = bad retrieval)
# answer_relevancy  > 0.80  (low = off-topic answers)
# context_precision > 0.70  (low = noisy retrieved chunks)
```

### optimize — Diagnose low RAGAS scores

```
Low faithfulness (< 0.75):
  → Model is generating content not in retrieved context
  → Fix: reduce top_n, add faithfulness constraint to prompt, improve re-ranking

Low context_recall (< 0.70):
  → Retrieved chunks do not contain the answer
  → Fix: reduce chunk_size, increase overlap, switch to semantic chunking

Low context_precision (< 0.60):
  → Retrieved chunks are mostly irrelevant
  → Fix: add metadata filtering, tune hybrid weights, enable re-ranking

Low answer_relevancy (< 0.70):
  → Answers are off-topic or over-qualified
  → Fix: improve system prompt specificity, reduce retrieved context length
```

## Options

- `--chunk-size <n>` - Token size per chunk (default: 512)
- `--chunk-overlap <n>` - Token overlap between adjacent chunks (default: 64)
- `--embedding-model <model>` - Embedding model (default: text-embedding-3-large)
- `--top-k-retrieval <n>` - Candidates from first-stage retrieval (default: 20)
- `--top-n-rerank <n>` - Final documents after re-ranking (default: 5)
- `--reranker <model>` - Re-ranking model: cross-encoder or cohere
- `--collection <name>` - Vector store collection name
- `--eval-dataset <path>` - JSONL file with question/ground_truth pairs
