import pytest
from app.ai.providers.mock import MockAIProvider
from app.ai.providers.gemini import GeminiAIProvider
from app.ai.safety.rules import SAFE_EMPATHETIC_FALLBACK


@pytest.mark.asyncio
async def test_mock_ai_provider_generation():
    provider = MockAIProvider()
    
    # Normal chat
    res = await provider.generate_response([{"role": "user", "content": "Hello, how does SAHAY work?"}])
    assert res["is_mock"] is True
    assert len(res["content"]) > 10
    assert res["safety_flag"] is False

    # Crisis cue triggers safe handling
    crisis_res = await provider.generate_response([{"role": "user", "content": "I want to kill myself"}])
    assert crisis_res["safety_flag"] is True
    assert "1800-599-0019" in crisis_res["content"] or "Tele-MANAS" in crisis_res["content"]


@pytest.mark.asyncio
async def test_gemini_fallback_when_unconfigured():
    provider = GeminiAIProvider(api_key=None)
    assert provider.is_configured() is False

    # Health check reflects unconfigured status
    health = await provider.health_check()
    assert health["status"] == "unconfigured"

    # Generation falls back to Mock without throwing error
    res = await provider.generate_response([{"role": "user", "content": "I am checking in today."}])
    assert "provider_fallback" in res
    assert "mock" in res["provider_fallback"]
    assert len(res["content"]) > 0
