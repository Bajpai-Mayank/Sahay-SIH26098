import re
from typing import List, Tuple

# Layer 1 Prohibited Phrases (Clinical, diagnostic certainty, unverified authority claims)
PROHIBITED_PHRASES = [
    "i diagnose",
    "clinical diagnosis",
    "clinical assessment",
    "psychiatric evaluation",
    "you have clinical depression",
    "you are diagnosed with",
    "you have ptsd",
    "you are suffering from bipolar",
    "mental health score",
    "risk score",
    "danger level",
    "psychiatric assessment score",
    "clinical risk rating",
    "authorities have been notified",
    "police have been called",
    "police are on their way",
    "emergency services are dispatched",
    "i prescribe",
    "you must take this medication",
]

# Patterns for clinical or legal certainty
PROHIBITED_REGEX = [
    re.compile(r"\bdiagnos(?:e|ed|is|ing)\b", re.IGNORECASE),
    re.compile(r"\bmental health score\b", re.IGNORECASE),
    re.compile(r"\bauthorities (?:have been|are) notified\b", re.IGNORECASE),
    re.compile(r"\bpolice (?:have been|are) (?:called|dispatched|notified)\b", re.IGNORECASE),
]

# Layer 1 Safety-Sensitive Cues (Self-harm, acute danger, violence)
SAFETY_CUE_PATTERNS = [
    re.compile(r"\b(?:kill|end)\s+myself\b", re.IGNORECASE),
    re.compile(r"\bwant to die\b", re.IGNORECASE),
    re.compile(r"\bsuicid(?:e|al)\b", re.IGNORECASE),
    re.compile(r"\bhurting myself\b", re.IGNORECASE),
    re.compile(r"\bhe is going to kill me\b", re.IGNORECASE),
    re.compile(r"\bthey are beating me\b", re.IGNORECASE),
    re.compile(r"\bin immediate danger\b", re.IGNORECASE),
    re.compile(r"\bweapon\b", re.IGNORECASE),
]

# Standard empathetic fallback when AI generation breaches boundary
SAFE_EMPATHETIC_FALLBACK = (
    "I hear you, and what you're sharing sounds difficult. You don't have to go through this alone. "
    "A counsellor from our support network has been notified to follow up with you. "
    "If you need immediate support, verified national helplines are available 24/7 (KIRAN: 1800-599-0019, Tele-MANAS: 14416)."
)

# Core system instructions for all LLM providers
SYSTEM_SAFETY_INSTRUCTION = (
    "You are SAHAY-AI, a supportive, empathetic conversational assistant for well-being monitoring. "
    "MANDATORY SAFETY BOUNDARIES:\n"
    "1. You are NOT a doctor, psychiatrist, or licensed clinical therapist.\n"
    "2. NEVER diagnose any mental or medical illness (do not use words like 'diagnose', 'clinical depression', 'PTSD', etc.).\n"
    "3. NEVER prescribe medications or medical treatments.\n"
    "4. NEVER claim that police or emergency services have been dispatched unless explicitly instructed by verified system parameters.\n"
    "5. NEVER refer to a user's status as a 'mental health score' or 'danger rating'; refer only to 'support priority' or 'follow-up recommendation'.\n"
    "6. Always be calm, respectful, supportive, non-judgmental, and encourage speaking with human caseworkers."
)


def detect_safety_cues(text: str) -> Tuple[bool, List[str]]:
    """
    Detect immediate safety-sensitive cues in user text.
    Returns (has_cues, list_of_matched_cues).
    """
    if not text:
        return False, []

    matched = []
    for pattern in SAFETY_CUE_PATTERNS:
        match = pattern.search(text)
        if match:
            matched.append(match.group(0))

    return len(matched) > 0, matched


def validate_ai_response(text: str) -> Tuple[bool, List[str], str]:
    """
    Validate AI model output against safety boundaries.
    Returns (is_safe, list_of_violations, sanitized_text).
    If violations are detected, sanitized_text provides the safe fallback.
    """
    if not text:
        return True, [], ""

    text_lower = text.lower()
    violations: List[str] = []

    # Substring checks
    for phrase in PROHIBITED_PHRASES:
        if phrase in text_lower:
            violations.append(phrase)

    # Regex checks
    for pattern in PROHIBITED_REGEX:
        match = pattern.search(text)
        if match and match.group(0).lower() not in violations:
            violations.append(match.group(0))

    if violations:
        return False, violations, SAFE_EMPATHETIC_FALLBACK

    return True, [], text
