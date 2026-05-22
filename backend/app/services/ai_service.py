import os
from dotenv import load_dotenv, find_dotenv
from ollama import Client

class AiService:
    """Service to interact with Ollama Cloud API."""

    def __init__(self, model: str = "gpt-oss:120b-cloud"):
        self._load_env()
        api_key = os.getenv("OLLAMA_API_KEY")
        if not api_key:
            raise ValueError("OLLAMA_API_KEY is not set!")
        
        self.client = Client(
            host='https://ollama.com',
            headers={'Authorization': f'Bearer {api_key}'}
        )
        self.model = model

    def _load_env(self):
        load_dotenv(find_dotenv())

    def ask(self, prompt: str) -> str:
        try:
            response = self.client.generate(
                model=self.model,
                prompt=prompt
            )
            if hasattr(response, "response"):
                return response.response
            elif isinstance(response, dict):
                return response.get("response", "")
            return str(response)
        except Exception as e:
            raise RuntimeError(f"Ollama Cloud API error: {e}")
