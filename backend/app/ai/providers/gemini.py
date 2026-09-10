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

logger = logging.getLogger("sahay.ai.gemini")
settings = get_settings()


class GeminiAIProvider(AIProvider):
    """
    Google Gemini AI adapter.
    Reads strictly from GEMINI_API_KEY.
    Falls back gracefully to MockAIProvider if unconfigured or error occurs and fallback enabled.
    """

    provider_name: str = "gemini"

    def __init__(self, api_key: Optional[str] = None, model_name: Optional[str] = None):
        self.api_key = api_key or settings.GEMINI_API_KEY
        self.model_name = model_name or settings.AI_MODEL or "gemini-1.5-flash"
        self._mock_fallback = MockAIProvider()

    def is_configured(self) -> bool:
        return bool(self.api_key and not self.api_key.startswith("your_") and not self.api_key == "AIzaSy...")

    async def generate_response(
        self,
        messages: List[Dict[str, str]],
        system_instruction: Optional[str] = None,
        **kwargs: Any,
    ) -> Dict[str, Any]:
        if not self.is_configured():
            if settings.AI_FALLBACK_TO_MOCK:
                logger.info("Gemini API key not configured; falling back to MockAIProvider")
                res = await self._mock_fallback.generate_response(messages, system_instruction, **kwargs)
                res["provider_fallback"] = "mock (gemini unconfigured)"
                return res
            raise ValueError("GEMINI_API_KEY is not configured in backend/.env")

        instruction = system_instruction or SYSTEM_SAFETY_INSTRUCTION

        # Format messages for Gemini API
        contents = []
        for msg in messages:
            role = "user" if msg.get("role") in ["user", "victim"] else "model"
            contents.append({"role": role, "parts": [{"text": msg.get("content", "")}]})

        url = f"https://generativelanguage.googleapis.com/v1beta/models/{self.model_name}:generateContent?key={self.api_key}"
        payload = {
            "systemInstruction": {"parts": [{"text": instruction}]},
            "contents": contents,
            "generationConfig": {
                "temperature": 0.4,
                "maxOutputTokens": 800,
            },
        }

        try:
            async with httpx.AsyncClient(timeout=settings.AI_TIMEOUT_SECONDS) as client:
                resp = await client.post(url, json=payload)
                resp.raise_for_status()
                data = resp.json()

            candidates = data.get("candidates", [])
            raw_text = ""
            if candidates:
                parts = candidates[0].get("content", {}).get("parts", [])
                if parts:
                    raw_text = parts[0].get("text", "")

            # Run safety boundary filter on model generation
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
            logger.error(f"Gemini API request failed: {e}")
            if settings.AI_FALLBACK_TO_MOCK:
                logger.warning("Falling back to MockAIProvider due to Gemini error")
                res = await self._mock_fallback.generate_response(messages, system_instruction, **kwargs)
                res["provider_fallback"] = f"mock (gemini error: {str(e)})"
                return res
            raise

    async def evaluate_risk(
        self,
        checkin_data: Dict[str, Any],
        history: Optional[List[Dict[str, Any]]] = None,
        **kwargs: Any,
    ) -> Dict[str, Any]:
        if not self.is_configured():
            if settings.AI_FALLBACK_TO_MOCK:
                res = await self._mock_fallback.evaluate_risk(checkin_data, history, **kwargs)
                res["provider_fallback"] = "mock (gemini unconfigured)"
                return res
            raise ValueError("GEMINI_API_KEY is not configured in backend/.env")

        prompt = (
            f"{SYSTEM_SAFETY_INSTRUCTION}\n\n"
            f"Analyze the following check-in data and output a JSON evaluation:\n"
            f"Check-in: {checkin_data}\n"
            f"Return JSON format:\n"
            f'{{"priority": "LOW|MODERATE|HIGH|URGENT", "score": int, "reasons": ["str"], "requires_human_review": bool}}'
        )

        try:
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{self.model_name}:generateContent?key={self.api_key}"
            payload = {
                "contents": [{"role": "user", "parts": [{"text": prompt}]}],
                "generationConfig": {"temperature": 0.1, "responseMimeType": "application/json"},
            }
            async with httpx.AsyncClient(timeout=settings.AI_TIMEOUT_SECONDS) as client:
                resp = await client.post(url, json=payload)
                resp.raise_for_status()
                # Parse JSON result safely
                import json
                text_content = resp.json()["candidates"][0]["content"]["parts"][0]["text"]
                parsed = json.loads(text_content)
                parsed["provider"] = self.provider_name
                parsed["model"] = self.model_name
                parsed["is_mock"] = False
                return parsed
        except Exception as e:
            logger.error(f"Gemini risk evaluation failed: {e}")
            if settings.AI_FALLBACK_TO_MOCK:
                res = await self._mock_fallback.evaluate_risk(checkin_data, history, **kwargs)
                res["provider_fallback"] = f"mock (gemini error: {str(e)})"
                return res
            raise

    async def health_check(self) -> Dict[str, Any]:
        if not self.is_configured():
            return {
                "status": "unconfigured",
                "provider": self.provider_name,
                "configured": False,
                "message": "GEMINI_API_KEY is not set in backend/.env; using mock fallback",
            }
        try:
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{self.model_name}?key={self.api_key}"
            async with httpx.AsyncClient(timeout=5) as client:
                resp = await client.get(url)
                if resp.status_code == 200:
                    return {
                        "status": "ok",
                        "provider": self.provider_name,
                        "configured": True,
                        "model": self.model_name,
                    }
                return {
                    "status": "degraded",
                    "provider": self.provider_name,
                    "configured": True,
                    "status_code": resp.status_code,
                }
        except Exception as e:
            return {
                "status": "unreachable",
                "provider": self.provider_name,
                "configured": True,
                "error": str(e),
            }
