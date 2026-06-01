from app.services.vector_db_service import VectorDBService

service = VectorDBService()
results = service.retrieve("Gdzie rozgrywa się akcja Antygony?", k=5)

for i, r in enumerate(results):
    score = r.score
    book = r.payload.get("book", "")
    chunk_idx = r.payload.get("metadata", {}).get("chunk_index", "?")
    ctx = r.payload.get("chunk_context", "")[:200]

    ctx_safe = ctx.encode("ascii", errors="replace").decode("ascii")
    print(f"\n--- Result {i+1} (score: {score:.4f}) ---")
    print(f"Book: {book}, chunk: {chunk_idx}")
    print(f"Context: {ctx_safe}")