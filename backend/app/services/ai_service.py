import os
import json
import requests
from dotenv import load_dotenv, find_dotenv
from ollama import Client


class AiService:
    def __init__(self, model: str = "deepseek-v4-pro:cloud"):
        self._load_env()
        self.ai_testing = self._get_bool_env("AI_TESTING", default=True)

        if self.ai_testing:
            self._init_ollama(model)
        else:
            self._init_openrouter(model)

    def _load_env(self):
        load_dotenv(find_dotenv())

    def _get_bool_env(self, key: str, default: bool = False) -> bool:
        val = os.getenv(key)
        if val is None:
            return default
        return val.strip().lower() == "true"

    def _init_ollama(self, model: str):
        api_key = os.getenv("OLLAMA_API_KEY")
        if not api_key:
            raise ValueError("OLLAMA_API_KEY is not set!")

        self.backend = "ollama"
        self.model = model

        self.client = Client(
            host="https://ollama.com",
            headers={"Authorization": f"Bearer {api_key}"}
        )

    def _ask_ollama(self, prompt: str) -> str:
        try:
            response = self.client.generate(
                model=self.model,
                prompt=prompt
            )

            if hasattr(response, "response"):
                return response.response
            if isinstance(response, dict):
                return response.get("response", "")

            return str(response)

        except Exception as e:
            raise RuntimeError(f"Ollama API error: {e}")

    def _init_openrouter(self, model: str):
        self.backend = "openrouter"
        self.model = model

        self.api_key = os.getenv("OPENROUTER_API_KEY")
        if not self.api_key:
            raise ValueError("OPENROUTER_API_KEY is not set!")

        self.site_url = os.getenv("SITE_URL", "")
        self.site_name = os.getenv("SITE_NAME", "")

    def _ask_openrouter(self, prompt: str) -> str:
        try:
            response = requests.post(
                url="https://openrouter.ai/api/v1/chat/completions",
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "HTTP-Referer": self.site_url,
                    "X-OpenRouter-Title": self.site_name,
                    "Content-Type": "application/json",
                },
                data=json.dumps({
                    "model": self.model,
                    "messages": [
                        {"role": "user", "content": prompt}
                    ]
                })
            )

            response.raise_for_status()
            data = response.json()

            return data["choices"][0]["message"]["content"]

        except Exception as e:
            raise RuntimeError(f"OpenRouter API error: {e}")

    def ask(self, prompt: str) -> str:
        if self.backend == "ollama":
            return self._ask_ollama(prompt)
        return self._ask_openrouter(prompt)