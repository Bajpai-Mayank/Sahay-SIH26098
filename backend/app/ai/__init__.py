from typing import Optional
from app.ai.providers.base import AIProvider
from app.ai.providers.mock import MockAIProvider
from app.ai.providers.gemini import GeminiAIProvider
from app.ai.providers.ollama import OllamaAIProvider
from app.ai.providers.huggingface import HuggingFaceAIProvider
from app.config import get_settings

settings = get_settings()


def get_ai_provider(provider_name: Optional[str] = None) -> AIProvider:
    """
    Factory to retrieve the active AI provider based on configuration or override.
    Supports: mock, gemini, ollama, huggingface.
    Defaults to MockAIProvider if unconfigured.
    """
    name = (provider_name or settings.AI_PROVIDER).lower()

    if name == "gemini":
        return GeminiAIProvider()
    elif name == "ollama":
        return OllamaAIProvider()
    elif name == "huggingface":
        return HuggingFaceAIProvider()
    return MockAIProvider()


__all__ = [
    "AIProvider",
    "MockAIProvider",
    "GeminiAIProvider",
    "OllamaAIProvider",
    "HuggingFaceAIProvider",
    "get_ai_provider",
]
