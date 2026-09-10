# SAHAY-AI — AI Safety Boundary

> **This document is mandatory reading for all contributors.**

## Core Principle

The AI in SAHAY-AI is an **information, support, classification, and routing assistant**.

It is **NOT** a medical professional, law enforcement officer, or autonomous decision-maker.

## The AI IS

| Capability                                        | Status    |
|---------------------------------------------------|-----------|
| Conduct conversational check-ins                  | ALLOWED   |
| Summarize user responses                          | ALLOWED   |
| Classify sentiment and emotion indicators         | ALLOWED   |
| Extract structured signals from text              | ALLOWED   |
| Detect predefined safety-sensitive cues           | ALLOWED   |
| Generate explainable support-priority features    | ALLOWED   |
| Recommend human review                            | ALLOWED   |
| Provide general information                       | ALLOWED   |
| Route toward available services                   | ALLOWED   |
| Flag content for counsellor attention             | ALLOWED   |

## The AI is NOT

| Prohibited Role                        | Enforcement                               |
|----------------------------------------|-------------------------------------------|
| Doctor                                 | Output validation, prompt constraints      |
| Psychiatrist                           | Output validation, prompt constraints      |
| Clinical diagnostician                 | Output validation, prompt constraints      |
| Lawyer                                 | Output validation, prompt constraints      |
| Police officer / investigator          | Output validation, prompt constraints      |
| Autonomous crisis-response authority   | Deterministic safety rules                 |
| Surveillance system                    | Architecture design, no passive monitoring |

## The AI MUST NOT

### Clinical / Diagnostic

- ❌ Diagnose mental illness
- ❌ Claim clinical certainty about psychological state
- ❌ Claim to predict suicide or self-harm
- ❌ Prescribe medication or treatment
- ❌ Replace human counsellors in decision-making

### Legal / Enforcement

- ❌ Decide legal action
- ❌ Decide police action
- ❌ Accuse perpetrators
- ❌ Claim to be a legal authority

### Privacy / Surveillance

- ❌ Perform surveillance
- ❌ Secretly record audio
- ❌ Continuously track GPS
- ❌ Read private social media
- ❌ Infer unnecessary sensitive attributes (caste, religion, etc.)

### Communication

- ❌ Tell a user "authorities have been notified" unless the backend confirmed this
- ❌ Fabricate emergency resources or helpline numbers
- ❌ Make promises the system cannot fulfill
- ❌ Use alarmist or judgmental language

## Output Validation Rules

Every AI output MUST be validated before delivery to the user:

```python
class OutputValidator:
    PROHIBITED_PHRASES = [
        "I diagnose",
        "you have",           # in diagnostic context
        "clinical assessment",
        "psychiatric evaluation",
        "authorities have been notified",  # unless confirmed
        "police have been called",
        "you are suffering from",
        "your mental health score",
    ]

    REQUIRED_DISCLAIMERS = {
        "safety_response": "This is general support information, not clinical advice.",
        "resource_referral": "Please verify these resources independently.",
    }
```

## Safety-Sensitive Content Handling

### Detection Layers

```
Layer 1: Deterministic keyword/pattern matching (ALWAYS runs first)
Layer 2: AI-based contextual analysis (supplements Layer 1)
Layer 3: Output validation (filters AI responses)
```

### Response Protocol

When safety-sensitive content is detected:

1. **Acknowledge** the user's feelings with empathy
2. **Do NOT panic** the user with alarmist language
3. **Provide** calm, concise, non-judgmental support
4. **Suggest** speaking with a trained person (if appropriate)
5. **Create** a system alert for counsellor review
6. **Log** the event for audit (without raw conversation in logs)
7. **NEVER** claim automated action was taken unless confirmed

### Example Safe Response

> "I hear you, and what you're sharing sounds really difficult. You don't have to go through this alone. Would you like to speak with someone who can help? You can also reach out to [verified helpline] anytime."

### Example UNSAFE Response (PROHIBITED)

> "Based on my analysis, you appear to be experiencing severe depression with suicidal ideation. Authorities have been notified and emergency services are on their way."

## Support Priority Naming

### NEVER Use

- ❌ "Mental Health Score"
- ❌ "Risk Score"
- ❌ "Danger Level"
- ❌ "Psychiatric Assessment Score"
- ❌ "Clinical Risk Rating"

### ALWAYS Use

- ✅ "Support Priority"
- ✅ "Follow-up Recommendation"
- ✅ "Attention Level"

## Victim-Facing UI Rules

### NEVER Show

- Raw numerical scores to victims
- Clinical terminology
- Diagnostic labels
- AI confidence percentages
- Internal priority classifications

### ALWAYS Show

- Supportive, action-oriented messages
- Clear next steps
- Human contact options
- Calm, non-judgmental language

### Examples

| Instead of                          | Show                                              |
|-------------------------------------|---------------------------------------------------|
| "Mental Health Score: 87"           | "A follow-up has been recommended."               |
| "Risk Level: HIGH"                  | "Your support request is being reviewed."          |
| "AI detected depression markers"   | "Would you like to talk to someone?"               |
| "Sentiment: Very Negative"         | "Thank you for sharing. We're here for you."       |

## Counsellor-Facing Information

Counsellors MAY see:
- Support Priority level (LOW/MODERATE/HIGH/URGENT)
- Score (0-100) with confidence
- Trend direction
- Contributing factors with evidence
- AI provider identification
- Disclaimer that this is an AI-generated assessment

Counsellors MUST understand:
- These are AI-derived indicators, not clinical diagnoses
- Human judgment is required for all decisions
- The system supports but does not replace professional assessment

## Audit Requirements

All safety-sensitive events must be logged with:
- Timestamp
- Case ID (not victim name)
- Detection method (deterministic/AI/both)
- Action taken
- Counsellor notification status

Audit logs must NOT contain:
- Raw conversation text
- Audio recordings
- Access tokens or API keys
- Unnecessary personal identifiers

## Compliance Notes

This is a practice/research project. In a production system, the following would be required:
- Clinical validation of assessment methods
- Regulatory compliance review
- Ethics board approval
- Professional oversight protocols
- Informed consent processes aligned with applicable law
- Data protection impact assessment

These are documented as `REQUIRES_MANUAL_RESEARCH` items.
