import json
import os
import uuid

from qdrant_client import QdrantClient, models
from app.services.embeddings_service import EmbeddingsService
from dotenv import load_dotenv, find_dotenv

load_dotenv(find_dotenv())

COLLECTION_NAME = "UstnApp"
DATA_PATH = os.path.join(os.path.dirname(__file__), "..", "..", "data", "qdrant_export.json")
BATCH_SIZE = 10


def build_embedding_text(payload: dict) -> str:
    book = payload.get("book", "")
    author = payload.get("author", "")
    chunk_context = payload.get("chunk_context", "")
    metadata = payload.get("metadata", {})

    epoch = metadata.get("epoch", "")
    characters = metadata.get("characters", [])
    themes = metadata.get("themes", [])

    parts = []
    parts.append(f"Książka: {book} ({author}, {epoch})")

    if characters:
        parts.append(f"Postacie: {', '.join(characters)}")

    if themes:
        parts.append(f"Tematy: {', '.join(themes)}")

    parts.append(f"Kontekst: {chunk_context}")

    return "\n".join(parts)


def load_data(path: str) -> list[dict]:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def upload_to_qdrant(data: list[dict]):
    client = QdrantClient(
        url=os.getenv("QDRANT_URL"),
        api_key=os.getenv("QDRANT_API_KEY"),
    )
    embeddings_service = EmbeddingsService()

    total = len(data)
    print(f"Uploading {total} points to collection '{COLLECTION_NAME}'...")

    for i in range(0, total, BATCH_SIZE):
        batch = data[i:i + BATCH_SIZE]
        points = []

        for item in batch:
            text_to_embed = build_embedding_text(item["payload"])
            vector = embeddings_service.create_embedding(text_to_embed)

            point_id = item.get("id", str(uuid.uuid4()))

            points.append(
                models.PointStruct(
                    id=point_id,
                    vector=vector,
                    payload=item["payload"],
                )
            )

        client.upsert(
            collection_name=COLLECTION_NAME,
            points=points,
        )

        uploaded = min(i + BATCH_SIZE, total)
        print(f"  [{uploaded}/{total}] uploaded")

    print(f"Done! {total} points uploaded to '{COLLECTION_NAME}'.")


def main():
    data = load_data(DATA_PATH)
    upload_to_qdrant(data)


if __name__ == "__main__":
    main()
