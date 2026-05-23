# RAG Architecture

> Retrieval-augmented generation systems — chunking, embedding, retrieval, reranking, generation, evaluation. The patterns that separate "RAG demo" from "RAG that doesn't hallucinate in production."

## Contents

- **Agent**: `rag-engineer` — designs RAG systems end-to-end with eval-driven iteration
- **Command**: `/rag` — architecture design, chunking strategies, retrieval tuning, eval harness
- **Skill**: pattern library for the 7 layers of a RAG system

## Key capabilities

- **Chunking strategies**: fixed-size, semantic, structural (markdown/code-aware), hierarchical
- **Embedding selection**: open-weight (BGE, E5, GTE) vs. API (OpenAI, Voyage, Cohere); domain fine-tuning when justified
- **Vector store choice**: Pinecone, Weaviate, Qdrant, pgvector, Milvus — operational trade-offs
- **Retrieval**: dense, sparse (BM25), hybrid; HyDE; query rewriting
- **Reranking**: cross-encoders, ColBERT, LLM rerankers; cost/latency vs. quality
- **Generation prompting**: chain-of-thought, structured output, citation-required, refusal patterns
- **Evaluation**: retrieval metrics (recall@k, MRR, NDCG) + generation metrics (faithfulness, answer relevance, citation accuracy)
- **Multilingual + code RAG**: special-case patterns for non-English + code corpora

## When to use

- Designing RAG from scratch
- RAG that "works in demo, fails in production" debugging
- Choosing vector DB / embedding model
- Building the eval harness BEFORE accumulating technical debt
- Reducing hallucinations
- Multi-turn RAG / RAG over agents

## Compatibility

LangChain, LlamaIndex, custom orchestration. All major embedding APIs + open-weight models. All major vector DBs.
