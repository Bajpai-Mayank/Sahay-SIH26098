from abc import ABC, abstractmethod
from typing import Any, Dict, List, Optional


class AIProvider(ABC):
    """
    Abstract interface for AI providers in SAHAY-AI.
    Ensures pluggable multi-provider architecture (Mock, Gemini, Ollama, HuggingFace).
    """

    provider_name: str = "base"
    model_name: str = "default"

    @abstractmethod
    async def generate_response(
        self,
        messages: List[Dict[str, str]],
        system_instruction: Optional[str] = None,
        **kwargs: Any,
    ) -> Dict[str, Any]:
        """
        Generate a conversational response given chat messages.
        Returns a dict: {"content": str, "provider": str, "model": str, "safety_flag": bool, ...}
        """
        pass

    @abstractmethod
    async def evaluate_risk(
        self,
        checkin_data: Dict[str, Any],
        history: Optional[List[Dict[str, Any]]] = None,
        **kwargs: Any,
    ) -> Dict[str, Any]:
        """
        Evaluate support priority indicators from a check-in.
        Returns a dict:
        {
            "priority": "LOW" | "MODERATE" | "HIGH" | "URGENT",
            "score": int (0-100),
            "confidence": float (0.0-1.0),
            "reasons": List[str],
            "requires_human_review": bool,
            "features": List[Dict[str, Any]]
        }
        """
        pass

    @abstractmethod
    async def health_check(self) -> Dict[str, Any]:
        """
        Check provider availability and connectivity.
        Returns a dict: {"status": "ok" | "degraded" | "unreachable", "provider": str, ...}
        """
        pass
