# RAG Patterns

Expert patterns for document chunking, embedding pipelines, hybrid search, cross-encoder re-ranking, and RAGAS evaluation.

## Pattern 1: Document Ingestion with Recursive Chunking

Parse and chunk documents with metadata preservation.

```python
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.document_loaders import PyPDFLoader, TextLoader
from langchain.schema import Document
import hashlib
from pathlib import Path

def ingest_documents(file_paths: list[str],
                     chunk_size: int = 512,
                     chunk_overlap: int = 64) -> list[Document]:
    """Load, parse, and chunk documents with source metadata."""
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=chunk_overlap,
        separators=["\n\n", "\n", ". ", " ", ""],
        length_function=len,
    )

    all_chunks = []
    for path in file_paths:
        ext = Path(path).suffix.lower()
        if ext == ".pdf":
            loader = PyPDFLoader(path)
        else:
            loader = TextLoader(path, encoding="utf-8")

        docs = loader.load()
        chunks = splitter.split_documents(docs)

        # Enrich metadata
        for i, chunk in enumerate(chunks):
            chunk.metadata.update({
                "source": Path(path).name,
                "chunk_id": i,
                "chunk_hash": hashlib.sha256(chunk.page_content.encode()).hexdigest()[:16],
                "char_count": len(chunk.page_content),
            })
        all_chunks.extend(chunks)

    print(f"Ingested {len(file_paths)} files → {len(all_chunks)} chunks")
    return all_chunks

# Usage
chunks = ingest_documents(["contracts/msa.pdf", "docs/policy.txt"],
                           chunk_size=512, chunk_overlap=64)
```

## Pattern 2: Embedding and Indexing with pgvector

Store document embeddings in PostgreSQL with pgvector.

```python
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import PGVector
from langchain.schema import Document
import os

CONNECTION_STRING = os.getenv("POSTGRES_CONNECTION_STRING")
COLLECTION_NAME = "legal_documents"

embeddings = OpenAIEmbeddings(
    model="text-embedding-3-large",
    dimensions=1536,          # Matryoshka: can reduce from 3072
)

# Create vector store and index documents
vectorstore = PGVector.from_documents(
    documents=chunks,
    embedding=embeddings,
    collection_name=COLLECTION_NAME,
    connection_string=CONNECTION_STRING,
    pre_delete_collection=False,   # set True to reindex
)

# For retrieval
retriever = vectorstore.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 20, "filter": {"source": "msa.pdf"}}
)

# Similarity score threshold
retriever = vectorstore.as_retriever(
    search_type="similarity_score_threshold",
    search_kwargs={"score_threshold": 0.75, "k": 10}
)
```

## Pattern 3: Hybrid Search with BM25 + Dense Vectors

Combine keyword and semantic retrieval with Reciprocal Rank Fusion.

```python
from langchain.retrievers import BM25Retriever, EnsembleRetriever
from langchain.vectorstores import Chroma
from langchain.embeddings import OpenAIEmbeddings

# Build dense retriever
texts = [doc.page_content for doc in chunks]
metadatas = [doc.metadata for doc in chunks]

vectorstore = Chroma.from_texts(
    texts=texts,
    embedding=OpenAIEmbeddings(model="text-embedding-3-large"),
    metadatas=metadatas,
)
dense_retriever = vectorstore.as_retriever(search_kwargs={"k": 20})

# Build sparse (BM25) retriever
bm25_retriever = BM25Retriever.from_texts(texts, metadatas=metadatas)
bm25_retriever.k = 20

# Hybrid: RRF fusion
ensemble_retriever = EnsembleRetriever(
    retrievers=[bm25_retriever, dense_retriever],
    weights=[0.4, 0.6],   # BM25: 40%, dense: 60%
)

def hybrid_search(query: str, top_k: int = 5) -> list:
    results = ensemble_retriever.get_relevant_documents(query)
    return results[:top_k]

docs = hybrid_search("indemnification clause maximum liability cap")
for doc in docs:
    print(f"[{doc.metadata['source']}] {doc.page_content[:150]}...")
```

## Pattern 4: Cross-Encoder Re-ranking

Re-rank top candidates with a cross-encoder for precision.

```python
from sentence_transformers import CrossEncoder
from langchain.schema import Document

# Load cross-encoder (runs locally, no API cost)
cross_encoder = CrossEncoder(
    "cross-encoder/ms-marco-MiniLM-L-6-v2",
    max_length=512,
)

def rerank_documents(query: str, candidate_docs: list[Document],
                     top_n: int = 5) -> list[Document]:
    """Score each (query, doc) pair with cross-encoder; return top_n."""
    pairs = [(query, doc.page_content) for doc in candidate_docs]
    scores = cross_encoder.predict(pairs)

    # Sort by score descending
    ranked = sorted(zip(scores, candidate_docs),
                    key=lambda x: x[0], reverse=True)

    for score, doc in ranked[:top_n]:
        doc.metadata["rerank_score"] = round(float(score), 4)

    return [doc for _, doc in ranked[:top_n]]

# Two-stage retrieval
candidates = hybrid_search(query, top_k=20)   # stage 1: fast, broad
reranked = rerank_documents(query, candidates, top_n=5)   # stage 2: precise

# Or use Cohere Rerank API
import cohere
co = cohere.Client(os.getenv("COHERE_API_KEY"))

def cohere_rerank(query: str, docs: list[Document], top_n: int = 5):
    response = co.rerank(
        model="rerank-english-v3.0",
        query=query,
        documents=[doc.page_content for doc in docs],
        top_n=top_n,
    )
    return [docs[r.index] for r in response.results]
```

## Pattern 5: RAGAS Pipeline Evaluation

Measure retrieval and generation quality with RAGAS metrics.

```python
from ragas import evaluate as ragas_evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_recall, context_precision
from datasets import Dataset
from langchain.chains import RetrievalQA
from langchain.chat_models import ChatAnthropic

# Build RAG chain
llm = ChatAnthropic(model="claude-opus-4-6")
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    retriever=ensemble_retriever,
    return_source_documents=True,
)

# Prepare evaluation dataset
eval_questions = [
    "What is the maximum liability cap in the MSA?",
    "Under what conditions can the agreement be terminated?",
    # ... 50+ questions for meaningful evaluation
]
eval_ground_truths = [
    "The maximum liability cap is limited to fees paid in the 12 months preceding the claim.",
    "Either party may terminate with 30 days written notice.",
    # ...
]

# Collect RAG outputs
rows = []
for question, ground_truth in zip(eval_questions, eval_ground_truths):
    result = qa_chain({"query": question})
    rows.append({
        "question": question,
        "answer": result["result"],
        "contexts": [doc.page_content for doc in result["source_documents"]],
        "ground_truth": ground_truth,
    })

ragas_dataset = Dataset.from_list(rows)
scores = ragas_evaluate(
    ragas_dataset,
    metrics=[faithfulness, answer_relevancy, context_recall, context_precision]
)
print(scores.to_pandas().mean())
# Target: faithfulness > 0.85, context_recall > 0.80
```

## Anti-Patterns

### Anti-Pattern 1: Fixed 512-Token Chunks for All Document Types
Code files split differently than legal contracts. PDFs with tables need table-aware parsing. Markdown should split at headers. Using the same RecursiveCharacterTextSplitter for all document types is lazy and hurts retrieval. Match chunking to document structure.

### Anti-Pattern 2: Vector-Only Retrieval (No Hybrid Search)
Dense vectors miss exact matches: "Section 12.3(b)", "ISO 27001", "RFC 2119". BM25 misses paraphrases and synonyms. Both alone underperform hybrid. Always combine with RRF — it costs nothing extra and consistently improves retrieval by 10-20%.

### Anti-Pattern 3: Evaluating RAG by Reading Outputs
Reading 10 answers and saying "looks good" is not evaluation. Hallucinations are polished and plausible-sounding. Run RAGAS on 50+ labeled questions. Faithfulness < 0.75 means the model is fabricating — regardless of how good the answers read.

### Anti-Pattern 4: Same Embedding Model for Query and Document (When Domain Differs)
Asymmetric retrieval: user queries are short, informal, interrogative. Documents are long, formal, declarative. `e5-mistral-7b-instruct` and `bge-large` are designed for asymmetric retrieval and handle this mismatch. Generic embeddings trained for symmetric tasks underperform.
