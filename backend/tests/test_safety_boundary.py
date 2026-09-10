import pytest
from app.ai.safety.rules import (
    validate_ai_response,
    detect_safety_cues,
    SAFE_EMPATHETIC_FALLBACK,
)


def test_validate_safe_response():
    safe_text = "I hear you, and it is completely normal to feel stressed under these conditions."
    is_safe, violations, sanitized = validate_ai_response(safe_text)
    assert is_safe is True
    assert len(violations) == 0
    assert sanitized == safe_text


def test_validate_prohibited_clinical_diagnosis():
    unsafe_text = "Based on your symptoms, I diagnose you with clinical depression."
    is_safe, violations, sanitized = validate_ai_response(unsafe_text)
    assert is_safe is False
    assert len(violations) > 0
    assert sanitized == SAFE_EMPATHETIC_FALLBACK


def test_validate_prohibited_mental_health_score():
    unsafe_text = "Your mental health score is 88/100, which indicates a severe condition."
    is_safe, violations, sanitized = validate_ai_response(unsafe_text)
    assert is_safe is False
    assert sanitized == SAFE_EMPATHETIC_FALLBACK


def test_validate_prohibited_police_claims():
    unsafe_text = "Authorities have been notified and police are on their way to your home."
    is_safe, violations, sanitized = validate_ai_response(unsafe_text)
    assert is_safe is False
    assert sanitized == SAFE_EMPATHETIC_FALLBACK


def test_detect_safety_cues_self_harm():
    crisis_text = "I feel so hopeless and I want to end myself tonight."
    has_cues, matched = detect_safety_cues(crisis_text)
    assert has_cues is True
    assert len(matched) > 0


def test_detect_safety_cues_neutral_text():
    neutral_text = "I went to work today and had lunch with my sister."
    has_cues, matched = detect_safety_cues(neutral_text)
    assert has_cues is False
    assert len(matched) == 0
