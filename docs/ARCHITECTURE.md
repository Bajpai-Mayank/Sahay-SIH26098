# SAHAY-AI Architecture

> Practice/research-grade AI-assisted victim well-being monitoring and early-support platform.

## System Overview

```
┌──────────────────────────────────────────────────────────────────┐
│                        FLUTTER CLIENT                            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐           │
│  │  Victim   │ │Counsellor│ │ District │ │  State   │           │
│  │   App     │ │Dashboard │ │ Admin    │ │  Admin   │           │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘           │
│       └─────────────┴────────────┴─────────────┘                 │
│                         │                                        │
│              ┌──────────┴──────────┐                             │
│              │  Network Layer      │                             │
│              │  (Dio + Interceptors)│                            │
│              └──────────┬──────────┘                             │
└─────────────────────────┼────────────────────────────────────────┘
                          │ HTTPS REST API
┌─────────────────────────┼────────────────────────────────────────┐
│                    FASTAPI BACKEND                                │
│  ┌──────────────────────┴──────────────────────┐                 │
│  │              API Gateway Layer               │                 │
│  │  (Auth Middleware, Rate Limiting, Logging)   │                 │
│  └──────────────────────┬──────────────────────┘                 │
│                         │                                        │
│  ┌──────────┬───────────┼───────────┬──────────┐                 │
│  │ Auth     │ Cases     │ Check-ins │ Chat     │                 │
│  │ Service  │ Service   │ Service   │ Service  │                 │
│  ├──────────┼───────────┼───────────┼──────────┤                 │
│  │ Alert    │ Assess-   │ Inter-    │Dashboard │                 │
│  │ Service  │ ment Svc  │ vention   │ Service  │                 │
│  └──────┬───┴─────┬─────┴─────┬─────┴────┬─────┘                │
│         │         │           │           │                      │
│  ┌──────┴─────────┴───────────┴───────────┴─────┐                │
│  │           AI Orchestrator                     │                │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌────────────┐   │               │
│  │  │ Mock │ │Ollama│ │Gemini│ │HuggingFace │   │               │
│  │  └──────┘ └──────┘ └──────┘ └────────────┘   │               │
│  └───────────────────────────────────────────────┘               │
│                         │                                        │
│  ┌──────────────────────┴──────────────────────┐                 │
│  │           Repository Layer                   │                 │
│  └──────────────────────┬──────────────────────┘                 │
└─────────────────────────┼────────────────────────────────────────┘
                          │
         ┌────────────────┼────────────────┐
    ┌────┴────┐    ┌──────┴──────┐   ┌─────┴─────┐
    │PostgreSQL│    │    Redis    │   │  Object   │
    │         │    │(Cache/Jobs) │   │  Storage  │
    └─────────┘    └─────────────┘   └───────────┘
```

## Frontend Architecture (Flutter)

### State Management: Riverpod

**Decision rationale:** Riverpod provides compile-time safety, testability via `ProviderContainer` overrides, no `BuildContext` dependency for service access, and excellent support for async operations. Documented in `DECISIONS.md`.

### Feature-Based Organization

```
lib/
├── app/
│   ├── app.dart                    # MaterialApp with router
│   ├── router.dart                 # GoRouter configuration
│   └── theme/
│       ├── app_theme.dart          # ThemeData definitions
│       ├── app_colors.dart         # Color palette
│       └── app_typography.dart     # Text styles
│
├── core/
│   ├── config/
│   │   ├── app_config.dart         # Environment configuration
│   │   └── api_config.dart         # API base URL, timeouts
│   ├── network/
│   │   ├── api_client.dart         # Dio instance with interceptors
│   │   ├── api_interceptor.dart    # Auth token injection
│   │   ├── api_exception.dart      # Typed API errors
│   │   └── connectivity.dart       # Network state monitoring
│   ├── security/
│   │   ├── secure_storage.dart     # FlutterSecureStorage wrapper
│   │   └── token_manager.dart      # Access/refresh token lifecycle
│   ├── storage/
│   │   ├── local_storage.dart      # SharedPreferences abstraction
│   │   └── draft_storage.dart      # Offline check-in drafts
│   ├── errors/
│   │   ├── app_exception.dart      # Exception hierarchy
│   │   └── error_handler.dart      # Global error handling
│   └── utils/
│       ├── date_utils.dart
│       ├── validators.dart
│       └── extensions.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── auth_repository.dart
│   │   │   └── auth_api.dart
│   │   ├── domain/
│   │   │   └── auth_state.dart
│   │   ├── presentation/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── widgets/
│   │   └── providers/
│   │       └── auth_provider.dart
│   │
│   ├── onboarding/
│   ├── victim/
│   ├── checkin/
│   ├── chat/
│   ├── voice/
│   ├── assessments/
│   ├── alerts/
│   ├── interventions/
│   ├── counsellor/
│   ├── dashboard/
│   └── profile/
│
└── shared/
    ├── widgets/
    │   ├── loading_widget.dart
    │   ├── error_widget.dart
    │   ├── empty_state_widget.dart
    │   └── retry_widget.dart
    └── models/
        ├── user.dart
        ├── case.dart
        └── pagination.dart
```

### Layer Responsibilities

| Layer           | Responsibility                                      |
|-----------------|-----------------------------------------------------|
| Presentation    | Widgets, screens, UI logic only                     |
| Providers       | Riverpod state management, async state              |
| Domain          | State models, business rules                        |
| Data            | Repository (combines sources), API calls            |

### Dependency Flow

```
Presentation → Providers → Repository → API/LocalStorage
```

No upward dependencies. No circular dependencies.

## Backend Architecture (FastAPI)

### Layered Organization

```
backend/
├── app/
│   ├── main.py                     # FastAPI app factory
│   ├── config/
│   │   ├── settings.py             # Pydantic BaseSettings
│   │   ├── database.py             # SQLAlchemy async engine
│   │   └── redis.py                # Redis connection
│   │
│   ├── api/
│   │   └── v1/
│   │       ├── router.py           # Aggregate API router
│   │       ├── auth.py
│   │       ├── users.py
│   │       ├── cases.py
│   │       ├── checkins.py
│   │       ├── conversations.py
│   │       ├── voice.py
│   │       ├── assessments.py
│   │       ├── alerts.py
│   │       ├── interventions.py
│   │       ├── dashboard.py
│   │       └── dependencies.py     # FastAPI Depends() factories
│   │
│   ├── services/
│   │   ├── auth_service.py
│   │   ├── case_service.py
│   │   ├── checkin_service.py
│   │   ├── conversation_service.py
│   │   ├── assessment_service.py
│   │   ├── alert_service.py
│   │   ├── intervention_service.py
│   │   ├── dashboard_service.py
│   │   └── voice_service.py
│   │
│   ├── repositories/
│   │   ├── base.py                 # Base repository with CRUD
│   │   ├── user_repository.py
│   │   ├── case_repository.py
│   │   └── ...
│   │
│   ├── models/
│   │   ├── base.py                 # SQLAlchemy Base
│   │   ├── user.py
│   │   ├── case.py
│   │   ├── checkin.py
│   │   ├── conversation.py
│   │   ├── assessment.py
│   │   ├── alert.py
│   │   ├── intervention.py
│   │   └── audit.py
│   │
│   ├── schemas/
│   │   ├── auth.py                 # Pydantic request/response
│   │   ├── user.py
│   │   ├── case.py
│   │   └── ...
│   │
│   ├── ai/
│   │   ├── __init__.py
│   │   ├── orchestrator.py         # Routes requests to provider
│   │   ├── schemas.py              # AI input/output schemas
│   │   ├── safety/
│   │   │   ├── boundary.py         # Safety rules engine
│   │   │   ├── content_filter.py
│   │   │   └── rules.py           # Deterministic safety rules
│   │   ├── providers/
│   │   │   ├── base.py             # AIProvider ABC
│   │   │   ├── mock.py
│   │   │   ├── ollama.py
│   │   │   ├── gemini.py
│   │   │   └── huggingface.py
│   │   └── prompts/
│   │       ├── checkin.py
│   │       ├── assessment.py
│   │       └── safety.py
│   │
│   ├── security/
│   │   ├── auth.py                 # JWT creation/verification
│   │   ├── password.py             # bcrypt hashing
│   │   ├── rbac.py                 # Role-based access control
│   │   └── permissions.py          # Permission definitions
│   │
│   ├── middleware/
│   │   ├── request_id.py           # X-Request-ID injection
│   │   ├── logging.py              # Structured request logging
│   │   ├── rate_limit.py           # Rate limiting
│   │   └── cors.py                 # CORS configuration
│   │
│   ├── workers/
│   │   ├── tasks.py                # Background task definitions
│   │   └── scheduler.py            # Periodic jobs
│   │
│   └── tests/
│       ├── conftest.py
│       ├── unit/
│       ├── integration/
│       ├── api/
│       ├── security/
│       └── ai/
│
├── alembic/
│   ├── alembic.ini
│   ├── env.py
│   └── versions/
│
├── requirements.txt
├── requirements-dev.txt
├── .env.example
├── Dockerfile
└── docker-compose.yml
```

### Request Flow

```
HTTP Request
    → CORS Middleware
    → Request ID Middleware
    → Logging Middleware
    → Rate Limit Middleware
    → Auth Middleware (JWT verification)
    → Route Handler
    → RBAC Check
    → Input Validation (Pydantic)
    → Service Layer (business logic)
    → Repository Layer (data access)
    → Response Serialization (Pydantic)
    → HTTP Response
```

## Database Architecture

See `DATABASE.md` for full schema. Summary:

### Logical Data Separation

| Domain              | Tables                                              |
|---------------------|-----------------------------------------------------|
| Identity            | users, roles                                        |
| Consent             | consents                                            |
| Case Management     | cases                                               |
| Interactions        | checkins, conversations, messages, audio_assets      |
| AI/Analysis         | assessments, assessment_features, support_priority_events |
| Response            | alerts, interventions                                |
| System              | notifications, service_directory, audit_logs         |

## AI Architecture

See `AI_ARCHITECTURE.md` for full design. Summary:

### Provider Abstraction

```python
class AIProvider(ABC):
    @abstractmethod
    async def analyze_text(self, text: str, context: dict) -> TextAnalysis: ...

    @abstractmethod
    async def generate_response(self, prompt: str, context: dict) -> str: ...

    @abstractmethod
    async def assess_support_priority(self, features: dict) -> SupportPriority: ...

    @abstractmethod
    async def detect_safety_cues(self, text: str) -> SafetyResult: ...
```

### Safety Architecture

```
Input → Deterministic Safety Rules (ALWAYS first)
                │
                ├── SAFE → AI Provider → Output Validation → Response
                │
                └── SAFETY_SENSITIVE → Human Escalation (bypass AI decision)
```

## Cross-Cutting Concerns

### Error Handling Strategy

| Layer      | Strategy                                            |
|------------|-----------------------------------------------------|
| Flutter UI | Try/catch → typed exceptions → user-friendly message|
| API Client | Dio interceptors → map HTTP codes → AppException    |
| FastAPI    | Exception handlers → structured error response      |
| Service    | Business exceptions with error codes                |
| Repository | Database exceptions → service exceptions            |

### Logging Strategy

| Component  | Tool                    | Format          |
|------------|-------------------------|-----------------|
| Flutter    | `logger` package        | Structured      |
| FastAPI    | `structlog`             | JSON            |
| PostgreSQL | Built-in logging        | Standard        |

### Security Layers

```
Client: Secure storage, certificate pinning (future), input sanitization
Transport: HTTPS (TLS 1.3)
API: JWT auth, rate limiting, CORS, request validation
Service: RBAC, object-level auth, business rule validation
Data: Parameterized queries, encryption at rest (future), audit logging
```
