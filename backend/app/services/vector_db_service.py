
from qdrant_client import QdrantClient, models
from app.services.embeddings_service import EmbeddingsService
from dotenv import load_dotenv, find_dotenv

import os

load_dotenv(find_dotenv())

class VectorDBService:
    def __init__(self):
        try:
            self.client = QdrantClient(
                url=os.getenv("QDRANT_URL"),
                api_key=os.getenv("QDRANT_API_KEY"),
                cloud_inference=True,
            )
            self.embeddings_service = EmbeddingsService()
        except Exception as e:
            raise ConnectionError(
                f"Failed to connect to Qdrant: {e}"
            )

    def retrieve(
        self, 
        query: str,
        k: int = 10
    ) -> list[dict]:
        return self.client.query_points(
            collection_name="UstnApp",
            query=self.embeddings_service.create_embedding(query),
            limit=k,
            with_payload=True
        ).points