# SAHAY-AI — Backend Foundation Implementation Report

**Document Version:** 1.0.0  
**Date:** September 2026  
**Status:** Completed & Fully Tested  

---

## 1. Executive Summary

The backend foundation for **SAHAY-AI** has been engineered from the ground up to support the SIH26094 concept as a research/practice-grade AI-assisted well-being monitoring and early-support platform.

The implementation strictly satisfies all project constraints:
1. **Zero Credential Hardcoding**: No API keys or connection strings are embedded in source code, chat, or git history. The system is 100% operational out of the box with the default `AI_PROVIDER=mock` and local SQLite fallback.
2. **AI Safety Boundaries**: Implements strict deterministic filtering against clinical diagnosis, psychiatric certainty, and unverified authority claims in accordance with `docs/AI_SAFETY_BOUNDARY.md`.
3. **Pluggable Multi-Provider AI Layer**: Seamlessly supports `mock`, Google `gemini`, local `ollama`, and `huggingface` with graceful fallback to mock mode if network issues or unconfigured keys occur.
4. **PostgreSQL & Supabase Compatibility**: SQLAlchemy 2.0 async engine with explicit PgBouncer transaction-pooler support (`statement_cache_size=0`).
5. **Role-Based Access Control (RBAC)**: Validates authenticated user roles (`VICTIM`, `COUNSELLOR`, `DISTRICT_ADMIN`, `STATE_ADMIN`, `NATIONAL_ADMIN`) and performs object-level case ownership checks.
6. **Complete Test Suite**: 16 automated tests covering health checks, auth flows, RBAC, safety boundaries, Support Priority triage, AI providers, conversations, alerts, and operational dashboards.

---

## 2. Architecture & File Structure

```
backend/
├── alembic.ini                   # Alembic configuration
├── alembic/                      # Database migrations
│   ├── env.py                    # Async migration environment
│   └── versions/                 # Auto-generated migrations
│       └── 33dc60b75b48_initial_schema.py
├── app/
│   ├── api/v1/                   # REST API Routers
│   │   ├── alerts.py             # Alerts acknowledgment & routing
│   │   ├── auth.py               # Register, login, token refresh
│   │   ├── cases.py              # Cases, consent, checkins, timeline, priority
│   │   ├── conversations.py      # Supportive chat & AI replies
│   │   ├── dashboards.py         # Counsellor, District, and State dashboards
│   │   ├── health.py             # Health and dependency diagnostics
│   │   ├── interventions.py      # Caseworker interventions
│   │   ├── router.py             # API v1 router aggregator
│   │   ├── users.py              # User profiles & preferences
│   │   └── voice.py              # Audio check-in upload, transcribe, acoustics
│   ├── ai/                       # AI Layer & Safety Boundaries
│   │   ├── providers/
│   │   │   ├── base.py           # Abstract AIProvider interface
│   │   │   ├── mock.py           # Offline deterministic provider
│   │   │   ├── gemini.py         # Google Gemini provider adapter
│   │   │   ├── ollama.py         # Local Ollama adapter
│   │   │   └── huggingface.py    # Hugging Face inference adapter
│   │   └── safety/
│   │       └── rules.py          # Prohibited phrases, safety cues, validators
│   ├── config/                   # Typed settings via pydantic-settings
│   │   └── settings.py
│   ├── db/                       # Database engine & base
│   │   ├── base.py               # Base class with UUID & timestamps
│   │   └── session.py            # Async engine with PgBouncer compatibility
│   ├── middleware/               # HTTP middlewares
│   │   ├── rate_limit.py         # Sliding-window limiter with memory fallback
│   │   └── request_id.py         # X-Request-ID propagation
│   ├── models/                   # 13 SQLAlchemy 2.0 ORM models
│   │   ├── alert.py, assessment.py, audio_asset.py, audit_log.py, case.py,
│   │   ├── checkin.py, consent.py, conversation.py, intervention.py,
│   │   ├── message.py, notification.py, role.py, service_directory.py, user.py
│   ├── schemas/                  # Pydantic v2 validation models
│   │   ├── alert.py, assessment.py, auth.py, case.py, checkin.py, common.py,
│   │   ├── conversation.py, dashboard.py, intervention.py, user.py
│   ├── security/                 # Security primitives
│   │   ├── jwt.py                # JWT creation, decode & validation
│   │   ├── password.py           # Bcrypt & PBKDF2 hashing
│   │   └── rbac.py               # Role checks & case-level authorization
│   ├── seed/
│   │   └── seed_data.py          # Synthetic demo seed (CASE-1042)
│   ├── services/                 # Core business services
│   │   ├── alert_service.py, auth_service.py, case_service.py, checkin_service.py,
│   │   ├── conversation_service.py, dashboard_service.py, intervention_service.py,
│   │   └── support_priority_service.py
│   └── storage/                  # Storage abstractions
│       ├── base.py, local.py, supabase.py
│   └── main.py                   # FastAPI application entry point
├── tests/                        # Pytest test suite (16 tests)
│   ├── conftest.py, test_ai_providers.py, test_alerts_interventions.py,
│   ├── test_auth.py, test_conversations.py, test_dashboards.py,
│   ├── test_health.py, test_safety_boundary.py, test_support_priority.py
├── pytest.ini
├── requirements.txt
└── .env.example
```

---

## 3. Support Priority Triage Engine

The Support Priority engine (`app/services/support_priority_service.py`) calculates triage indicators without ever claiming diagnostic certainty:
- **Priority Levels**: `LOW`, `MODERATE`, `HIGH`, `URGENT`
- **Score Range**: 0 to 100
- **Trend Computation**: Compares sequential check-ins (`STABLE`, `INCREASING`, `DECREASING`)
- **Explainability**: Outputs structured `AssessmentFeature` records explaining contributing signals (e.g. self-reported distress index, keyword flags).
- **Human-in-the-Loop Escalation**: Automatically generates `CRITICAL` or `WARNING` alerts when priority reaches `URGENT` or `HIGH`, notifying assigned caseworkers.
- **Safety Fallback**: If unsafe generation or crisis cues are identified, outputs the verified safe text containing national helplines (**KIRAN: 1800-599-0019**, **Tele-MANAS: 14416**).

---

## 4. Verification & Test Results

The test suite executed with Pytest using a clean isolated SQLite test database:
```
============================= test session starts =============================
platform win32 -- Python 3.14.6, pytest-9.1.1
tests/test_ai_providers.py::test_mock_ai_provider_generation PASSED      [  6%]
tests/test_ai_providers.py::test_gemini_fallback_when_unconfigured PASSED [ 12%]
tests/test_alerts_interventions.py::test_alerts_and_interventions_flow PASSED [ 18%]
tests/test_auth.py::test_register_and_login_flow PASSED                  [ 25%]
tests/test_conversations.py::test_conversation_and_ai_reply_flow PASSED  [ 31%]
tests/test_dashboards.py::test_dashboards_flow PASSED                    [ 37%]
tests/test_health.py::test_health_endpoint PASSED                        [ 43%]
tests/test_health.py::test_health_db_endpoint PASSED                     [ 50%]
tests/test_health.py::test_health_dependencies_endpoint PASSED           [ 56%]
tests/test_safety_boundary.py::test_validate_safe_response PASSED        [ 62%]
tests/test_safety_boundary.py::test_validate_prohibited_clinical_diagnosis PASSED [ 68%]
tests/test_safety_boundary.py::test_validate_prohibited_mental_health_score PASSED [ 75%]
tests/test_safety_boundary.py::test_validate_prohibited_police_claims PASSED [ 81%]
tests/test_safety_boundary.py::test_detect_safety_cues_self_harm PASSED  [ 87%]
tests/test_safety_boundary.py::test_detect_safety_cues_neutral_text PASSED [ 93%]
tests/test_support_priority.py::test_checkin_and_support_priority_flow PASSED [100%]

============================= 16 passed in 5.81s ==============================
```

---

## 5. Next Steps for Integration
1. Configure credentials in `backend/.env` according to [BACKEND_CREDENTIAL_CHECKLIST.md](file:///d:/Sahay/docs/BACKEND_CREDENTIAL_CHECKLIST.md).
2. Wire Flutter frontend API repository to `http://localhost:8000/api/v1`.
