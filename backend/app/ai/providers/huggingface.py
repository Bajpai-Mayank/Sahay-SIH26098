import logging
from typing import Any, Dict, List, Optional
import httpx

from app.ai.providers.base import AIProvider
from app.ai.providers.mock import MockAIProvider
from app.ai.safety.rules import validate_ai_response, SAFE_EMPATHETIC_FALLBACK
from app.config import get_settings

logger = logging.getLogger("sahay.ai.huggingface")
settings = get_settings()


class HuggingFaceAIProvider(AIProvider):
    """
    Hugging Face Inference API provider.
    Reads strictly from HF_TOKEN.
    """

    provider_name: str = "huggingface"

    def __init__(self, token: Optional[str] = None, model_name: Optional[str] = None):
        self.token = token or settings.HF_TOKEN
        self.model_name = model_name or "mistralai/Mistral-7B-Instruct-v0.2"
        self._mock_fallback = MockAIProvider()

    def is_configured(self) -> bool:
        return bool(self.token and not self.token.startswith("your_"))

    async def generate_response(
        self,
        messages: List[Dict[str, str]],
        system_instruction: Optional[str] = None,
        **kwargs: Any,
    ) -> Dict[str, Any]:
        if not self.is_configured():
            if settings.AI_FALLBACK_TO_MOCK:
                res = await self._mock_fallback.generate_response(messages, system_instruction, **kwargs)
                res["provider_fallback"] = "mock (hf_token unconfigured)"
                return res
            raise ValueError("HF_TOKEN is not configured in backend/.env")

        prompt = "\n".join([f"{m.get('role', 'user')}: {m.get('content', '')}" for m in messages])
        headers = {"Authorization": f"Bearer {self.token}"}
        url = f"https://api-inference.huggingface.co/models/{self.model_name}"

        try:
            async with httpx.AsyncClient(timeout=settings.AI_TIMEOUT_SECONDS) as client:
                resp = await client.post(url, headers=headers, json={"inputs": prompt})
                resp.raise_for_status()
                data = resp.json()
                raw_text = data[0].get("generated_text", "") if isinstance(data, list) else str(data)

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
            logger.error(f"Hugging Face request failed: {e}")
            if settings.AI_FALLBACK_TO_MOCK:
                res = await self._mock_fallback.generate_response(messages, system_instruction, **kwargs)
                res["provider_fallback"] = f"mock (hf error: {str(e)})"
                return res
            raise

    async def evaluate_risk(
        self,
        checkin_data: Dict[str, Any],
        history: Optional[List[Dict[str, Any]]] = None,
        **kwargs: Any,
    ) -> Dict[str, Any]:
        res = await self._mock_fallback.evaluate_risk(checkin_data, history, **kwargs)
        res["provider"] = self.provider_name
        return res

    async def health_check(self) -> Dict[str, Any]:
        if not self.is_configured():
            return {"status": "unconfigured", "provider": self.provider_name, "message": "HF_TOKEN not set"}
        try:
            url = f"https://api-inference.huggingface.co/status/{self.model_name}"
            async with httpx.AsyncClient(timeout=5) as client:
                resp = await client.get(url, headers={"Authorization": f"Bearer {self.token}"})
                return {"status": "ok" if resp.status_code == 200 else "degraded", "provider": self.provider_name}
        except Exception as e:
            return {"status": "unreachable", "provider": self.provider_name, "error": str(e)}
