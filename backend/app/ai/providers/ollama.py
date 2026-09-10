import logging
from typing import Any, Dict, List, Optional
import httpx

from app.ai.providers.base import AIProvider
from app.ai.providers.mock import MockAIProvider
from app.ai.safety.rules import (
    SYSTEM_SAFETY_INSTRUCTION,
    validate_ai_response,
    SAFE_EMPATHETIC_FALLBACK,
)
from app.config import get_settings

logger = logging.getLogger("sahay.ai.ollama")
settings = get_settings()


class OllamaAIProvider(AIProvider):
    """
    Local Ollama provider adapter.
    Calls local server at OLLAMA_BASE_URL (e.g. http://localhost:11434).
    """

    provider_name: str = "ollama"

    def __init__(self, base_url: Optional[str] = None, model_name: Optional[str] = None):
        self.base_url = (base_url or settings.OLLAMA_BASE_URL).rstrip("/")
        self.model_name = model_name or "llama3:latest"
        self._mock_fallback = MockAIProvider()

    async def generate_response(
        self,
        messages: List[Dict[str, str]],
        system_instruction: Optional[str] = None,
        **kwargs: Any,
    ) -> Dict[str, Any]:
        instruction = system_instruction or SYSTEM_SAFETY_INSTRUCTION
        ollama_messages = [{"role": "system", "content": instruction}]
        for m in messages:
            ollama_messages.append({"role": m.get("role", "user"), "content": m.get("content", "")})

        try:
            async with httpx.AsyncClient(timeout=settings.AI_TIMEOUT_SECONDS) as client:
                resp = await client.post(
                    f"{self.base_url}/api/chat",
                    json={"model": self.model_name, "messages": ollama_messages, "stream": False},
                )
                resp.raise_for_status()
                data = resp.json()
                raw_text = data.get("message", {}).get("content", "")

            is_safe, violations, sanitized = validate_ai_response(raw_text)
            return {
                "content": sanitized if is_safe else SAFE_EMPATHETIC_FALLBACK,
                "provider": self.provider_name,
                "model": self.model_name,
                "safety_flag": not is_safe,
                "violations": violations,
                "is_mock": False,
            }
        except Exception as e:
            logger.error(f"Ollama generation failed: {e}")
            if settings.AI_FALLBACK_TO_MOCK:
                res = await self._mock_fallback.generate_response(messages, system_instruction, **kwargs)
                res["provider_fallback"] = f"mock (ollama error: {str(e)})"
                return res
            raise

    async def evaluate_risk(
        self,
        checkin_data: Dict[str, Any],
        history: Optional[List[Dict[str, Any]]] = None,
        **kwargs: Any,
    ) -> Dict[str, Any]:
        if settings.AI_FALLBACK_TO_MOCK:
            res = await self._mock_fallback.evaluate_risk(checkin_data, history, **kwargs)
            res["provider"] = self.provider_name
            return res
        return await self._mock_fallback.evaluate_risk(checkin_data, history, **kwargs)

    async def health_check(self) -> Dict[str, Any]:
        try:
            async with httpx.AsyncClient(timeout=3) as client:
                resp = await client.get(f"{self.base_url}/api/tags")
                if resp.status_code == 200:
                    models = [m.get("name") for m in resp.json().get("models", [])]
                    return {
                        "status": "ok",
                        "provider": self.provider_name,
                        "base_url": self.base_url,
                        "available_models": models,
                    }
                return {"status": "degraded", "provider": self.provider_name, "status_code": resp.status_code}
        except Exception as e:
            return {"status": "unreachable", "provider": self.provider_name, "error": str(e)}
