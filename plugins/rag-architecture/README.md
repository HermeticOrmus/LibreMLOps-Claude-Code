# rag-architecture

Retrieval-augmented generation with recursive chunking, semantic chunking, embedding model selection, pgvector/Pinecone/Weaviate indexing, hybrid search (BM25 + dense vectors with RRF), cross-encoder re-ranking, and RAGAS pipeline evaluation.

## What This Plugin Does

Covers the full RAG pipeline: document ingestion with PDF/text parsing, recursive and semantic chunking strategies, embedding with OpenAI text-embedding-3-large or open-source bge-large, vector store indexing (pgvector, Pinecone, Weaviate, Chroma), hybrid search combining BM25 keyword retrieval with dense vector retrieval via Reciprocal Rank Fusion, two-stage re-ranking with cross-encoder or Cohere Rerank, and RAGAS evaluation measuring faithfulness, answer relevancy, context recall, and context precision.

## When to Use

- Building a document Q&A system over PDFs, contracts, or internal docs
- Choosing between chunking strategies for different document types
- Implementing hybrid search to handle both exact-match (codes, names) and semantic queries
- Adding a cross-encoder re-ranking stage to improve precision@5
- Evaluating a RAG system's hallucination rate and retrieval quality with RAGAS
- Diagnosing low RAGAS scores (bad retrieval vs bad generation vs bad chunking)
- Scaling from Chroma (development) to pgvector or Pinecone (production)

## Components

| Component | Description |
|-----------|-------------|
| `agents/rag-architect` | Expert in chunking, embeddings, hybrid search, re-ranking, RAGAS |
| `skills/rag-patterns` | Recursive chunking, pgvector indexing, hybrid retrieval, cross-encoder, RAGAS |
| `commands/rag` | `/rag build\|query\|evaluate\|optimize` workflows |

## Key Concepts

**Chunking Strategy Determines Retrieval Quality**
The wrong chunk size fragments information that needs to stay together (tables, code blocks, multi-sentence arguments) or creates chunks so large they dilute relevance. Sentence-window retrieval offers the best of both: sentence-level precision with paragraph-level context on retrieval.

**Hybrid Search is Non-Negotiable**
Dense vectors excel at semantic similarity. BM25 excels at exact keyword match. A legal RAG system that uses vector-only retrieval will miss "Section 4.2(c)" and "ISO/IEC 27001:2022" — exact strings that BM25 finds trivially. Reciprocal Rank Fusion (RRF) combines both without hyperparameter tuning.

**Re-ranking Doubles Precision**
First-stage retrieval optimizes recall (broad, fast). Cross-encoder re-ranking optimizes precision (slow, expensive, context-aware). A bi-encoder embedding cannot consider query and document jointly — a cross-encoder can. Two-stage architecture is the standard for production RAG.

**RAGAS Before Shipping**
Human evaluation of 10 answers is insufficient and biased. Run RAGAS on 50+ labeled (question, ground_truth) pairs. Low faithfulness = model hallucinating. Low context_recall = retriever not finding answers. Both need different fixes.

## Quick Start

```bash
pip install langchain langchain-community ragas openai pgvector sentence-transformers rank_bm25
```

```python
from langchain.text_splitter import RecursiveCharacterTextSplitter
splitter = RecursiveCharacterTextSplitter(chunk_size=512, chunk_overlap=64)
chunks = splitter.split_documents(documents)
```
