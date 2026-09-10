# SAHAY-AI — Privacy & Security Design

## Overview

Security is built into the architecture from Phase 4, not bolted on later.
This is a practice/research project, but implements production-grade security patterns.

## Authentication

### Password Security

| Property         | Value                                     |
|------------------|-------------------------------------------|
| Algorithm        | bcrypt (via passlib)                      |
| Cost factor      | 12 (configurable)                         |
| Min length       | 8 characters                              |
| Complexity       | At least 1 uppercase, 1 lowercase, 1 digit|

### Token Strategy

| Token Type     | Lifetime    | Storage (Client)          | Storage (Server)    |
|----------------|-------------|---------------------------|---------------------|
| Access Token   | 15 min      | Memory (Riverpod state)   | Stateless (JWT)     |
| Refresh Token  | 7 days      | flutter_secure_storage    | DB (for revocation) |

### JWT Claims

```json
{
  "sub": "user-uuid",
  "roles": ["victim"],
  "iat": 1694361600,
  "exp": 1694362500,
  "jti": "unique-token-id"
}
```

### Token Refresh Flow

```
Access token expires
    → Client sends refresh token to /auth/refresh
    → Server validates refresh token
    → Server issues new access + refresh token pair
    → Old refresh token is invalidated (rotation)
    → Client stores new tokens
```

## Authorization — RBAC

### Role Hierarchy

```
state_admin > district_admin > counsellor > victim
```

### Permission Matrix

| Resource           | Victim          | Counsellor       | District Admin  | State Admin     |
|--------------------|-----------------|-------------------|-----------------|-----------------|
| Own profile        | RW              | RW                | RW              | RW              |
| Own case           | R               | —                 | —               | —               |
| Assigned cases     | —               | RW                | —               | —               |
| District cases     | —               | —                 | R               | —               |
| All cases          | —               | —                 | —               | Aggregate only  |
| Check-in (submit)  | W (own)         | —                 | —               | —               |
| Check-in (view)    | R (own)         | R (assigned)      | —               | —               |
| Conversations      | RW (own)        | R (assigned)      | —               | —               |
| Assessments        | —               | R (assigned)      | —               | —               |
| Alerts             | —               | RW (assigned)     | R (district)    | Aggregate       |
| Interventions      | R (own status)  | RW (assigned)     | R (district)    | Aggregate       |
| Dashboard          | —               | Own caseload      | District        | State/National  |
| Admin settings     | —               | —                 | District config | System config   |

### Object-Level Authorization

Every data access checks:
```python
def authorize_case_access(user: User, case: Case) -> bool:
    if user.has_role("victim"):
        return case.victim_id == user.id
    if user.has_role("counsellor"):
        return user.id in case.assigned_counsellor_ids
    if user.has_role("district_admin"):
        return case.district == user.district
    if user.has_role("state_admin"):
        return False  # No individual case access by default
    return False
```

## Input Validation

### Client-Side (Flutter)
- Form validation before submission
- Input length limits
- Character filtering for injection prevention
- No raw SQL or code in inputs

### Server-Side (FastAPI)
- Pydantic models for all request bodies
- String length limits
- Enum validation for constrained fields
- UUID format validation
- SQL injection prevention (parameterized queries via SQLAlchemy)
- XSS prevention (no raw HTML rendering)

## Rate Limiting

Redis-backed sliding window rate limiter.
Per-user and per-IP limits.
See `API.md` for endpoint-specific limits.

## Secrets Management

### NEVER Commit
- `.env` files
- API keys
- Database credentials
- JWT secret keys
- Encryption keys

### .env.example

```env
# Database
DATABASE_URL=postgresql+asyncpg://sahay:password@localhost:5432/sahay_db

# Redis
REDIS_URL=redis://localhost:6379/0

# JWT
JWT_SECRET_KEY=change-this-to-a-random-secret
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=7

# AI
AI_PROVIDER=mock
OLLAMA_BASE_URL=http://localhost:11434
GEMINI_API_KEY=
HF_TOKEN=

# App
APP_NAME=SAHAY-AI
APP_ENV=development
DEBUG=true
CORS_ORIGINS=http://localhost:3000,http://localhost:8080

# Storage
STORAGE_BACKEND=local
STORAGE_PATH=./storage
S3_BUCKET=
S3_ACCESS_KEY=
S3_SECRET_KEY=
S3_ENDPOINT=
```

## Data Protection

### Data Classification

| Classification | Examples                              | Handling                              |
|----------------|---------------------------------------|---------------------------------------|
| PUBLIC         | Service directory, general info       | No restrictions                       |
| INTERNAL       | Aggregate statistics, system config   | Auth required                         |
| CONFIDENTIAL   | Case data, check-ins, assessments     | Auth + RBAC + object-level auth       |
| SENSITIVE      | Conversations, audio, identity data   | Auth + RBAC + audit + encryption*     |

*Encryption at rest is a future enhancement.

### Data Minimization

- Collect only necessary information
- Audio retention is time-limited (`retention_until` field)
- Conversation logs are not included in audit logs
- Aggregate dashboards use pre-computed statistics

### Consent

- Explicit consent required before data collection
- Separate consent types (data_collection, voice_recording, ai_analysis)
- Consent records are timestamped and versioned
- Consent can be revoked (affects future processing)

## Audit Logging

### What IS Logged

| Event                           | Details Logged                                    |
|---------------------------------|---------------------------------------------------|
| Login/logout                    | User ID, timestamp, IP                            |
| Case access                    | User ID, case ID, action, timestamp               |
| Assessment created             | Assessment ID, provider, priority level            |
| Alert acknowledged/assigned    | Alert ID, user, action                             |
| Intervention created/updated   | Intervention ID, user, status change               |
| Consent granted/revoked        | Consent type, user, timestamp                      |
| Admin actions                  | Action type, user, resource                        |
| Security events                | Failed logins, rate limit hits, unauthorized access |

### What is NOT Logged

- Raw conversation content
- Audio recordings or transcripts
- Access tokens or refresh tokens
- API keys
- Password hashes
- Raw check-in response text

## Threat Model (Practice Project Context)

| Threat                          | Mitigation                                        | Status          |
|---------------------------------|---------------------------------------------------|-----------------|
| Credential stuffing             | Rate limiting, bcrypt, account lockout (future)   | PARTIAL         |
| Token theft                     | Short-lived tokens, secure storage, HTTPS          | IMPLEMENTED     |
| SQL injection                   | SQLAlchemy parameterized queries                   | IMPLEMENTED     |
| XSS                             | No raw HTML rendering, CSP headers (future)       | PARTIAL         |
| CSRF                            | SameSite cookies (if used), CORS                   | IMPLEMENTED     |
| Unauthorized data access        | RBAC + object-level auth                           | IMPLEMENTED     |
| API abuse                       | Rate limiting                                      | IMPLEMENTED     |
| Sensitive data exposure         | Encrypted transport, minimal logging               | IMPLEMENTED     |
| AI prompt injection             | Input sanitization, output validation              | IMPLEMENTED     |
| AI hallucination (false alert)  | Human-in-the-loop, confidence scores               | IMPLEMENTED     |
| Insider threat                  | Audit logging, least privilege                     | PARTIAL         |

## Network Security

- All API communication over HTTPS (TLS 1.2+)
- CORS configured for specific origins
- HSTS headers (production)
- No sensitive data in URL query parameters
- Request IDs for traceability

## Flutter Client Security

- Tokens stored in `flutter_secure_storage` (platform keychain/keystore)
- No sensitive data in `SharedPreferences`
- No API keys in client code
- No raw conversation data persisted beyond session
- Offline drafts contain minimal structured data only
- Certificate pinning (future enhancement)
