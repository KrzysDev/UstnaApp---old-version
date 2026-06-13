import os
import json
import httpx
from dotenv import load_dotenv, find_dotenv
from ollama import Client
from typing import List

class EmbeddingsService:
    def __init__(self):
        load_dotenv(find_dotenv())
        self.ai_testing = os.getenv("AI_TESTING", "true").strip().lower() == "true"

        if self.ai_testing:
            self.model_name = os.getenv("EMBEDDINGS_MODEL", "qwen3-embedding:0.6b")
            self.host = os.getenv("OLLAMA_URL", "http://localhost:11434")
            self.client = Client(host=self.host)
        else:
            self.model_name = "google/gemini-embedding-2"
            self.api_key = os.getenv("OPENROUTER_API_KEY")
            if not self.api_key:
                raise ValueError("OPENROUTER_API_KEY is not set!")
            self.site_url = os.getenv("SITE_URL", "")
            self.site_name = os.getenv("SITE_NAME", "")

    def create_embedding(self, text: str) -> List[float]:
        if not text or not text.strip():
            raise ValueError("Text cannot be empty")

        if self.ai_testing:
            response = self.client.embed(
                model=self.model_name,
                input=text
            )
            embedding = response["embeddings"][0]
        else:
            try:
                with httpx.Client() as client:
                    response = client.post(
                        url="https://openrouter.ai/api/v1/embeddings",
                        headers={
                            "Authorization": f"Bearer {self.api_key}",
                            "HTTP-Referer": self.site_url,
                            "X-OpenRouter-Title": self.site_name,
                            "Content-Type": "application/json",
                        },
                        content=json.dumps({
                            "model": self.model_name,
                            "input": text,
                            "dimensions": 1024
                        }),
                        timeout=30.0
                    )
                    response.raise_for_status()
                    embedding = response.json()["data"][0]["embedding"]
            except Exception as e:
                raise RuntimeError(f"OpenRouter Embeddings API error: {e}")

        if len(embedding) != 1024:
            raise ValueError(
                f"Expected 1024 dimensions, got {len(embedding)}"
            )

        return embedding