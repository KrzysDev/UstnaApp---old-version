from ollama import Client
from typing import List, Union

class EmbeddingsService:
    def __init__(
        self,
        model_name: str = "qwen3-embedding:0.6b",
        host: str = "http://localhost:11434"
    ):
        self.client = Client(host=host)
        self.model_name = model_name

    def create_embedding(self, text: str) -> List[float]:

        if not text or not text.strip():
            raise ValueError("Text cannot be empty")

        response = self.client.embed(
            model=self.model_name,
            input=text
        )

        embedding = response["embeddings"][0]

        if len(embedding) != 1024:
            raise ValueError(
                f"Expected 1024 dimensions, got {len(embedding)}"
            )

        return embedding