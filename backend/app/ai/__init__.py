from typing import Optional
from app.ai.providers.base import AIProvider
from app.ai.providers.mock import MockAIProvider
from app.ai.providers.gemini import GeminiAIProvider
from app.ai.providers.ollama import OllamaAIProvider
from app.ai.providers.huggingface import HuggingFaceAIProvider
from app.ai.providers.kimi import KimiK3Provider
from app.config import get_settings

settings = get_settings()


def get_ai_provider(provider_name: Optional[str] = None) -> AIProvider:
    """
    Factory to retrieve the active AI provider based on configuration or override.
    Supports: mock, gemini, ollama, huggingface, kimi, nvidia.
    Defaults to MockAIProvider if unconfigured.
    """
    name = (provider_name or settings.AI_PROVIDER).lower()

    if name == "gemini":
        return GeminiAIProvider()
    elif name == "ollama":
        return OllamaAIProvider()
    elif name == "huggingface":
        return HuggingFaceAIProvider()
    elif name in ["kimi", "nvidia", "kimi-k3"]:
        return KimiK3Provider()
    return MockAIProvider()


__all__ = [
    "AIProvider",
    "MockAIProvider",
    "GeminiAIProvider",
    "OllamaAIProvider",
    "HuggingFaceAIProvider",
    "KimiK3Provider",
    "get_ai_provider",
]
