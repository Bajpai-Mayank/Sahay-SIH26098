from typing import Any, Dict, List, Optional
from app.ai.providers.base import AIProvider
from app.ai.safety.rules import detect_safety_cues, validate_ai_response, SAFE_EMPATHETIC_FALLBACK


class MockAIProvider(AIProvider):
    """
    Deterministic offline AI provider for SAHAY-AI.
    Ensures 100% testability without any external cloud credentials or network calls.
    """

    provider_name: str = "mock"
    model_name: str = "mock-rules-v1"

    async def generate_response(
        self,
        messages: List[Dict[str, str]],
        system_instruction: Optional[str] = None,
        **kwargs: Any,
    ) -> Dict[str, Any]:
        """Generate deterministic conversational responses based on message cues."""
        last_message = messages[-1]["content"] if messages else ""
        has_cues, matched_cues = detect_safety_cues(last_message)

        if has_cues:
            content = (
                "I hear you, and it sounds like you are carrying a lot right now. "
                "Your well-being is very important. I have marked this for priority caseworker check-in. "
                "You can also reach 24/7 national helplines anytime at 1800-599-0019 (KIRAN) or 14416 (Tele-MANAS)."
            )
            safety_flag = True
        elif any(w in last_message.lower() for w in ["anxious", "scared", "sad", "hopeless", "crying", "alone"]):
            content = (
                "Thank you for sharing how you are feeling. It is completely understandable to feel this way. "
                "Would you like to try a short breathing exercise, or would you prefer me to leave a note for your counsellor?"
            )
            safety_flag = False
        else:
            content = (
                "Thank you for checking in today. I am noting your responses. "
                "Remember to take things one step at a time today, and let us know if there is any specific support you need."
            )
            safety_flag = False

        # Run safety boundary validator
        is_safe, violations, sanitized = validate_ai_response(content)

        return {
            "content": sanitized if is_safe else SAFE_EMPATHETIC_FALLBACK,
            "provider": self.provider_name,
            "model": self.model_name,
            "safety_flag": safety_flag,
            "cues_detected": matched_cues,
            "violations": violations,
            "is_mock": True,
        }

    async def evaluate_risk(
        self,
        checkin_data: Dict[str, Any],
        history: Optional[List[Dict[str, Any]]] = None,
        **kwargs: Any,
    ) -> Dict[str, Any]:
        """
        Evaluate support priority deterministically from checkin data.
        Maps to LOW, MODERATE, HIGH, or URGENT.
        """
        notes = checkin_data.get("notes") or ""
        responses = checkin_data.get("responses") or {}
        mood_rating = checkin_data.get("mood_rating")  # 1 to 5
        distress_level = checkin_data.get("distress_level")  # 1 to 10

        has_cues, matched_cues = detect_safety_cues(notes)
        for val in responses.values():
            if isinstance(val, str):
                cues_found, cues = detect_safety_cues(val)
                if cues_found:
                    has_cues = True
                    matched_cues.extend(cues)

        features: List[Dict[str, Any]] = []
        reasons: List[str] = []

        if has_cues:
            priority = "URGENT"
            score = 90
            reasons.append(f"Safety cue pattern detected: {', '.join(set(matched_cues))}")
            reasons.append("Immediate caseworker outreach strongly recommended")
            requires_human_review = True
            features.append({"name": "safety_cues", "value": 1.0, "source": "keyword_matching", "evidence": f"Cues: {matched_cues}"})
        elif distress_level is not None and distress_level >= 8:
            priority = "HIGH"
            score = 75
            reasons.append(f"Elevated self-reported distress index ({distress_level}/10)")
            reasons.append("Prioritize for same-day counsellor check-in")
            requires_human_review = True
            features.append({"name": "distress_level", "value": distress_level / 10.0, "source": "checkin", "evidence": f"Self-reported distress {distress_level}"})
        elif (distress_level is not None and distress_level >= 5) or (mood_rating is not None and mood_rating <= 2):
            priority = "MODERATE"
            score = 50
            reasons.append("Moderate distress or low mood reported")
            reasons.append("Follow-up within standard 48-hour monitoring window")
            requires_human_review = False
            features.append({"name": "mood_distress_combo", "value": 0.5, "source": "checkin", "evidence": f"Mood: {mood_rating}, Distress: {distress_level}"})
        else:
            priority = "LOW"
            score = 15
            reasons.append("Routine positive check-in indicators")
            reasons.append("Maintain standard regular schedule")
            requires_human_review = False
            features.append({"name": "routine_stability", "value": 0.15, "source": "checkin", "evidence": "Normal baseline indicators"})

        return {
            "priority": priority,
            "score": score,
            "confidence": 0.95,
            "reasons": reasons,
            "requires_human_review": requires_human_review,
            "features": features,
            "trend": "STABLE",
            "provider": self.provider_name,
            "model": self.model_name,
            "is_mock": True,
        }

    async def health_check(self) -> Dict[str, Any]:
        """Mock provider is always available and healthy."""
        return {
            "status": "ok",
            "provider": self.provider_name,
            "model": self.model_name,
            "message": "Mock AI provider active (deterministic offline mode)",
        }
