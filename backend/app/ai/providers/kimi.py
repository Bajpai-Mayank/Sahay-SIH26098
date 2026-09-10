import logging
import os
from typing import Any, Dict, List, Optional
import httpx
import requests

from app.ai.providers.base import AIProvider
from app.ai.providers.mock import MockAIProvider
from app.ai.safety.rules import (
    SYSTEM_SAFETY_INSTRUCTION,
    validate_ai_response,
    SAFE_EMPATHETIC_FALLBACK,
)
from app.config import get_settings

logger = logging.getLogger("sahay.ai.kimi")
settings = get_settings()


class KimiK3Provider(AIProvider):
    """
    Kimi K3 (moonshotai/kimi-k3) integration hosted on NVIDIA NIM API.
    Can be used via both async AIProvider interface (for FastAPI endpoints)
    and synchronous chat() method.
    """

    provider_name: str = "kimi"

    def __init__(
        self,
        api_key: Optional[str] = None,
        base_url: Optional[str] = None,
        model_name: Optional[str] = None,
    ):
        raw_key = api_key or settings.NVIDIA_API_KEY or os.getenv("NVIDIA_API_KEY")
        if raw_key and raw_key.strip().startswith("Bearer "):
            raw_key = raw_key.strip()[7:].strip()
        self.api_key = raw_key
        self.base_url = (
            base_url
            or settings.NVIDIA_NIM_BASE_URL
            or os.getenv("NVIDIA_NIM_BASE_URL", "https://integrate.api.nvidia.com/v1")
        ).rstrip("/")
        self.model_name = (
            model_name
            or settings.KIMI_K3_MODEL
            or os.getenv("KIMI_K3_MODEL", "moonshotai/kimi-k3")
        )
        self._mock_fallback = MockAIProvider()

    def is_configured(self) -> bool:
        return bool(self.api_key and not self.api_key.startswith("your_") and not self.api_key.startswith("nvapi-placeholder"))

    def chat(self, message: str) -> str:
        """
        Synchronous chat method matching the user specification.
        """
        if not self.is_configured():
            if settings.AI_FALLBACK_TO_MOCK:
                return "Thank you for checking in. A counsellor is available to review your well-being notes."
            raise ValueError("NVIDIA_API_KEY is not configured in backend/.env")

        response = requests.post(
            f"{self.base_url}/chat/completions",
            headers={
                "Authorization": f"Bearer {self.api_key}",
                "Accept": "application/json",
            },
            json={
                "model": self.model_name,
                "messages": [{"role": "user", "content": message}],
                "max_tokens": 4096,
                "temperature": 1,
                "reasoning_effort": "max",
                "stream": False,
            },
            timeout=30,
        )
        response.raise_for_status()
        data = response.json()
        raw_text = data["choices"][0]["message"]["content"]
        is_safe, _, sanitized = validate_ai_response(raw_text)
        return sanitized if is_safe else SAFE_EMPATHETIC_FALLBACK

    async def generate_response(
        self,
        messages: List[Dict[str, str]],
        system_instruction: Optional[str] = None,
        **kwargs: Any,
    ) -> Dict[str, Any]:
        """
        Async chat generation for FastAPI endpoints with safety filters.
        """
        if not self.is_configured():
            if settings.AI_FALLBACK_TO_MOCK:
                logger.info("NVIDIA/Kimi API key not configured; falling back to MockAIProvider")
                res = await self._mock_fallback.generate_response(messages, system_instruction, **kwargs)
                res["provider_fallback"] = "mock (nvidia unconfigured)"
                return res
            raise ValueError("NVIDIA_API_KEY is not configured in backend/.env")

        instruction = system_instruction or SYSTEM_SAFETY_INSTRUCTION
        formatted_msgs = [{"role": "system", "content": instruction}]
        for m in messages:
            formatted_msgs.append({
                "role": m.get("role", "user"),
                "content": m.get("content", ""),
            })

        try:
            async with httpx.AsyncClient(timeout=settings.AI_TIMEOUT_SECONDS) as client:
                resp = await client.post(
                    f"{self.base_url}/chat/completions",
                    headers={
                        "Authorization": f"Bearer {self.api_key}",
                        "Accept": "application/json",
                    },
                    json={
                        "model": self.model_name,
                        "messages": formatted_msgs,
                        "max_tokens": 4096,
                        "temperature": 0.7,
                        "stream": False,
                    },
                )
                resp.raise_for_status()
                data = resp.json()
                raw_text = data["choices"][0]["message"]["content"]

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
            logger.error(f"Kimi K3 NIM request failed: {e}")
            if settings.AI_FALLBACK_TO_MOCK:
                res = await self._mock_fallback.generate_response(messages, system_instruction, **kwargs)
                res["provider_fallback"] = f"mock (kimi error: {str(e)})"
                return res
            raise

    async def evaluate_risk(
        self,
        checkin_data: Dict[str, Any],
        history: Optional[List[Dict[str, Any]]] = None,
        **kwargs: Any,
    ) -> Dict[str, Any]:
        """
        Evaluate support priority through Kimi K3 or deterministic mock fallback.
        """
        if not self.is_configured() or settings.AI_FALLBACK_TO_MOCK:
            res = await self._mock_fallback.evaluate_risk(checkin_data, history, **kwargs)
            res["provider"] = self.provider_name
            res["model"] = self.model_name
            return res

        prompt = (
            f"{SYSTEM_SAFETY_INSTRUCTION}\n\n"
            f"Analyze this well-being check-in:\n{checkin_data}\n\n"
            f"Return a strict JSON format:\n"
            f'{{"priority": "LOW|MODERATE|HIGH|URGENT", "score": int, "reasons": ["reason1"]}}'
        )

        try:
            async with httpx.AsyncClient(timeout=settings.AI_TIMEOUT_SECONDS) as client:
                resp = await client.post(
                    f"{self.base_url}/chat/completions",
                    headers={
                        "Authorization": f"Bearer {self.api_key}",
                        "Accept": "application/json",
                    },
                    json={
                        "model": self.model_name,
                        "messages": [{"role": "user", "content": prompt}],
                        "max_tokens": 1000,
                        "temperature": 0.1,
                        "stream": False,
                    },
                )
                resp.raise_for_status()
                import json
                raw_text = resp.json()["choices"][0]["message"]["content"]
                parsed = json.loads(raw_text)
                parsed["provider"] = self.provider_name
                parsed["model"] = self.model_name
                return parsed
        except Exception as e:
            logger.warning(f"Kimi risk parsing fallback: {e}")
            res = await self._mock_fallback.evaluate_risk(checkin_data, history, **kwargs)
            res["provider"] = self.provider_name
            return res

    async def health_check(self) -> Dict[str, Any]:
        if not self.is_configured():
            return {
                "status": "unconfigured",
                "provider": self.provider_name,
                "model": self.model_name,
                "message": "NVIDIA_API_KEY not configured in backend/.env",
            }
        try:
            async with httpx.AsyncClient(timeout=5) as client:
                resp = await client.get(
                    f"{self.base_url}/models",
                    headers={"Authorization": f"Bearer {self.api_key}"},
                )
                return {
                    "status": "ok" if resp.status_code == 200 else "degraded",
                    "provider": self.provider_name,
                    "model": self.model_name,
                }
        except Exception as e:
            return {
                "status": "unreachable",
                "provider": self.provider_name,
                "error": str(e),
            }
