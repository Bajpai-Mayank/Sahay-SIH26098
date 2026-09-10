# SAHAY-AI — AI Architecture

## Overview

The AI layer is **isolated from business logic** via a provider abstraction. The system MUST remain fully functional using `MockProvider` when no external AI APIs are available.

## Provider Abstraction

```python
from abc import ABC, abstractmethod
from .schemas import (
    TextAnalysis,
    SupportPriority,
    SafetyResult,
    ConversationResponse,
    VoiceAnalysis,
)

class AIProvider(ABC):
    """Abstract base class for all AI providers."""

    @abstractmethod
    async def analyze_text(
        self, text: str, language: str, context: dict | None = None
    ) -> TextAnalysis:
        """Analyze text for sentiment, emotion, safety cues, and structured signals."""
        ...

    @abstractmethod
    async def generate_response(
        self, prompt: str, conversation_history: list[dict], context: dict | None = None
    ) -> ConversationResponse:
        """Generate a conversational response for check-in or support chat."""
        ...

    @abstractmethod
    async def assess_support_priority(
        self, features: dict, history: list[dict] | None = None
    ) -> SupportPriority:
        """Compute support priority from extracted features."""
        ...

    @abstractmethod
    async def detect_safety_cues(
        self, text: str, language: str
    ) -> SafetyResult:
        """Detect safety-sensitive content in user input."""
        ...

    @abstractmethod
    async def extract_checkin_features(
        self, checkin_data: dict, language: str
    ) -> dict:
        """Extract structured features from check-in responses."""
        ...

    async def analyze_voice(
        self, transcript: str, acoustic_features: dict | None = None
    ) -> VoiceAnalysis:
        """Optional: Analyze voice transcript with acoustic features."""
        raise NotImplementedError("Voice analysis not supported by this provider")

    async def health_check(self) -> bool:
        """Check if the provider is available."""
        return True
```

## Providers

### MockProvider
- **Status:** IMPLEMENTED (Phase 7)
- **Purpose:** Development, testing, demos
- **Behaviour:** Returns deterministic, configurable responses
- **No external dependencies**
- Supports scenario-based responses (normal, distressed, safety-sensitive)
- Configurable latency simulation

### OllamaProvider
- **Status:** PLANNED (Phase 9)
- **Purpose:** Local LLM inference
- **Models:** Gemma 2B/7B, Qwen 2.5, Phi-3, Llama 3
- **Requires:** Ollama server running locally
- **Env:** `OLLAMA_BASE_URL=http://localhost:11434`

### GeminiProvider
- **Status:** PLANNED (Phase 9)
- **Purpose:** Cloud LLM via Google AI API
- **Models:** Gemini 1.5 Flash, Gemini 1.5 Pro
- **Requires:** API key
- **Env:** `GEMINI_API_KEY=...`

### HuggingFaceProvider
- **Status:** PLANNED (Phase 9)
- **Purpose:** Specialized NLP models (sentiment, emotion, NER, embeddings)
- **Models:** Task-specific models from HF Hub
- **Requires:** HF token (optional for many models)
- **Env:** `HF_TOKEN=...`

## AI Orchestrator

The orchestrator routes AI requests to the configured provider and applies safety boundaries:

```python
class AIOrchestrator:
    def __init__(self, provider: AIProvider, safety_engine: SafetyEngine):
        self.provider = provider
        self.safety = safety_engine

    async def process_message(self, message: str, context: dict) -> ProcessingResult:
        # 1. ALWAYS check safety first (deterministic rules)
        safety_result = self.safety.check(message)
        if safety_result.is_safety_sensitive:
            return self._escalate_to_human(safety_result)

        # 2. Analyze text via AI provider
        analysis = await self.provider.analyze_text(message, context["language"])

        # 3. AI-based safety check (secondary)
        ai_safety = await self.provider.detect_safety_cues(message, context["language"])

        # 4. Merge deterministic + AI safety
        if ai_safety.requires_escalation:
            return self._escalate_to_human(ai_safety)

        # 5. Generate response
        response = await self.provider.generate_response(...)

        # 6. Validate output against safety boundary
        validated = self.safety.validate_output(response)

        return ProcessingResult(analysis=analysis, response=validated)
```

## Output Schemas

### TextAnalysis

```json
{
  "language_detected": "hi",
  "sentiment": {
    "label": "negative",
    "score": 0.78
  },
  "emotions": [
    {"label": "fear", "score": 0.65},
    {"label": "sadness", "score": 0.42}
  ],
  "safety_cues": [],
  "extracted_signals": {
    "sleep_difficulty": true,
    "threat_mentioned": false,
    "isolation_indicated": true
  }
}
```

### SupportPriority

```json
{
  "priority": "HIGH",
  "score": 72,
  "confidence": 0.81,
  "trend": "INCREASING",
  "reasons": [
    "Fear-related response",
    "Sleep difficulty reported",
    "Increasing trend over 3 check-ins"
  ],
  "requires_human_review": true,
  "feature_contributions": {
    "self_reported_distress": 0.25,
    "fear_indicators": 0.20,
    "sleep_difficulty": 0.15,
    "isolation": 0.12
  }
}
```

### SafetyResult

```json
{
  "is_safe": true,
  "is_safety_sensitive": false,
  "detected_cues": [],
  "requires_escalation": false,
  "recommended_action": "continue",
  "confidence": 0.95
}
```

## Safety-Sensitive Detection

### Deterministic Rules (Always Applied First)

Keywords and patterns for:
- Self-harm indicators
- Threat indicators
- Crisis language
- Immediate danger references

### AI-Based Detection (Secondary)

- Contextual understanding beyond keyword matching
- Nuanced language interpretation
- Multi-language support

### Escalation Path

```
Safety cue detected
    → Flag message
    → Generate calm, supportive response
    → Create CRITICAL alert
    → Notify assigned counsellor
    → Log for audit
    → DO NOT claim authorities notified (unless backend confirmed)
    → DO NOT make clinical assessments
    → Provide general support resources if available
```

## Support Priority Computation

### Feature Sources

| Feature                    | Source           | Weight Range |
|----------------------------|------------------|-------------|
| Self-reported distress     | Check-in         | 0.15 - 0.25|
| Recent change              | Check-in delta   | 0.05 - 0.15|
| Sleep/daily functioning    | Check-in         | 0.10 - 0.15|
| Fear/threat indicators     | Text analysis    | 0.15 - 0.25|
| Social isolation           | Text analysis    | 0.05 - 0.15|
| Repeated support requests  | Behaviour        | 0.05 - 0.10|
| Missed check-ins           | Behaviour        | 0.05 - 0.10|
| Engagement change          | Behaviour        | 0.05 - 0.10|
| Text sentiment/emotion     | Text analysis    | 0.10 - 0.15|
| Voice acoustic features    | Voice analysis   | 0.05 - 0.10|

### Priority Thresholds (Configurable)

| Priority   | Score Range | Action                          |
|------------|-------------|---------------------------------|
| LOW        | 0 - 30      | Standard monitoring             |
| MODERATE   | 31 - 55     | Enhanced monitoring             |
| HIGH       | 56 - 80     | Counsellor review recommended   |
| URGENT     | 81 - 100    | Immediate counsellor attention  |

### Trend Computation

```
INSUFFICIENT_DATA: < 3 data points
STABLE:           |Δ| < threshold over window
INCREASING:       Δ > threshold (worsening)
DECREASING:       Δ < -threshold (improving)
```

## Multimodal Pipeline

### Text Pipeline

```
Raw Text Input
    ├── Language Detection (fasttext / AI provider)
    ├── Translation (if non-English, IndicTrans2 / API)
    ├── Sentiment Analysis
    ├── Emotion Detection
    ├── Safety Cue Detection (deterministic + AI)
    ├── Structured Signal Extraction
    └── Feature Vector → Support Priority
```

### Voice Pipeline (Phase 10)

```
Audio Input
    ├── Consent Verification ← MANDATORY
    ├── Temporary Secure Storage
    ├── Speech-to-Text (Whisper / Indic ASR)
    ├── Text Pipeline (above)
    ├── Acoustic Feature Extraction
    │   ├── Speech rate
    │   ├── Pause duration/frequency
    │   ├── Pitch (F0) statistics
    │   ├── Energy/loudness
    │   └── Hesitation/fluency markers
    ├── Feature Fusion (text + acoustic)
    └── Combined Feature Vector → Support Priority
```

## Prompt Engineering

### Principles

1. Never claim clinical/diagnostic authority
2. Always output strict JSON when structured data requested
3. Include confidence scores
4. Reference only available evidence
5. Use calm, supportive, non-judgmental language
6. Support Hindi and English
7. Include system prompts defining AI role boundaries

### Prompt Templates

Stored in `backend/app/ai/prompts/` as Python modules with template strings.
Each template includes:
- System prompt (role definition + constraints)
- User prompt (structured input)
- Output schema (expected JSON format)
- Examples (few-shot when beneficial)

## Fallback Strategy

```
Primary Provider → Timeout/Error
    → Retry (1x with backoff)
    → Fallback to MockProvider
    → Log degradation event
    → Continue with mock response
    → Flag response as "ai_degraded": true
```

## Environment Configuration

```env
# AI Provider Selection
AI_PROVIDER=mock                        # mock | ollama | gemini | huggingface

# Model Selection
AI_MODEL=                               # Provider-specific model name

# Ollama
OLLAMA_BASE_URL=http://localhost:11434

# Gemini
GEMINI_API_KEY=                         # NEVER commit this

# Hugging Face
HF_TOKEN=                              # NEVER commit this

# Safety
AI_SAFETY_STRICT=true                  # Enable strict safety mode
AI_MAX_RETRIES=1
AI_TIMEOUT_SECONDS=30
AI_FALLBACK_TO_MOCK=true               # Auto-fallback on provider failure
```
