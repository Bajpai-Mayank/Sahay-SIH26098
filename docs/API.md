# SAHAY-AI — API Design

## Base URL

```
Development: http://localhost:8000/api/v1
Production:  https://api.sahay-ai.example/api/v1
```

## Authentication

All endpoints except `/auth/register`, `/auth/login`, and `/auth/refresh` require a valid JWT in the `Authorization: Bearer <token>` header.

### Standard Error Response

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable error message",
    "details": [],
    "request_id": "uuid"
  }
}
```

### HTTP Status Codes

| Code | Usage                                      |
|------|--------------------------------------------|
| 200  | Successful GET/PATCH                       |
| 201  | Successful POST (resource created)         |
| 204  | Successful DELETE                          |
| 400  | Validation error                           |
| 401  | Missing or invalid authentication          |
| 403  | Authenticated but not authorized           |
| 404  | Resource not found                         |
| 409  | Conflict (duplicate, idempotency)          |
| 422  | Unprocessable entity                       |
| 429  | Rate limited                               |
| 500  | Internal server error                      |

---

## Endpoints

### Authentication

```
POST   /auth/register              Register new user
POST   /auth/login                 Login, receive tokens
POST   /auth/refresh               Refresh access token
POST   /auth/logout                Invalidate refresh token
```

#### POST /auth/register

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecureP@ss1",
  "full_name": "Test User",
  "role": "victim",
  "preferred_language": "en"
}
```

**Response (201):**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "full_name": "Test User",
  "role": "victim",
  "created_at": "2026-09-10T15:00:00Z"
}
```

#### POST /auth/login

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecureP@ss1"
}
```

**Response (200):**
```json
{
  "access_token": "jwt...",
  "refresh_token": "jwt...",
  "token_type": "bearer",
  "expires_in": 900,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "Test User",
    "roles": ["victim"]
  }
}
```

---

### Users

```
GET    /users/me                   Get current user profile
PATCH  /users/me                   Update profile
PATCH  /users/me/preferences       Update preferences
```

---

### Cases

```
POST   /cases                      Create a new case
GET    /cases                      List cases (filtered by role)
GET    /cases/{id}                 Get case details
PATCH  /cases/{id}                 Update case status
```

**Authorization:**
- Victim: own cases only
- Counsellor: assigned cases
- District Admin: cases in their district
- State Admin: aggregate only (no individual case detail by default)

---

### Consent

```
GET    /cases/{id}/consent         Get consent records
POST   /cases/{id}/consent         Grant/update consent
```

#### POST /cases/{id}/consent

**Request:**
```json
{
  "consent_type": "data_collection",
  "granted": true,
  "consent_version": "1.0"
}
```

---

### Check-ins

```
POST   /cases/{id}/checkins        Submit a check-in
GET    /cases/{id}/checkins        List check-ins for a case
GET    /cases/{id}/timeline        Get full case timeline
```

#### POST /cases/{id}/checkins

**Request:**
```json
{
  "checkin_type": "scheduled",
  "responses": {
    "mood": 3,
    "sleep_quality": 2,
    "safety_feeling": 4,
    "daily_functioning": 3,
    "additional_notes": "Feeling better today"
  },
  "mood_rating": 3,
  "distress_level": 4,
  "idempotency_key": "uuid-from-client"
}
```

**Response (201):**
```json
{
  "id": "uuid",
  "case_id": "uuid",
  "checkin_type": "scheduled",
  "mood_rating": 3,
  "submitted_at": "2026-09-10T15:00:00Z",
  "assessment_triggered": true
}
```

---

### Conversations

```
POST   /conversations              Start a new conversation
POST   /conversations/{id}/messages Send a message
GET    /conversations/{id}          Get conversation with messages
```

#### POST /conversations/{id}/messages

**Request:**
```json
{
  "content": "I've been feeling anxious lately",
  "message_type": "text"
}
```

**Response (201):**
```json
{
  "user_message": {
    "id": "uuid",
    "content": "I've been feeling anxious lately",
    "sender_type": "user",
    "created_at": "2026-09-10T15:00:00Z"
  },
  "ai_response": {
    "id": "uuid",
    "content": "Thank you for sharing that. Can you tell me more about what's been making you feel anxious?",
    "sender_type": "ai",
    "metadata": {
      "provider": "mock",
      "confidence": 0.85
    },
    "created_at": "2026-09-10T15:00:01Z"
  }
}
```

---

### Voice

```
POST   /voice/upload               Upload audio recording
POST   /voice/{id}/transcribe      Trigger transcription
GET    /voice/{id}/analysis        Get voice analysis results
```

**Status:** PLANNED (Phase 10)

---

### Assessments

```
POST   /cases/{id}/assessments     Trigger assessment
GET    /cases/{id}/assessments     List assessments
GET    /cases/{id}/support-priority Get current support priority
GET    /cases/{id}/trend           Get priority trend
```

#### GET /cases/{id}/support-priority

**Response (200):**
```json
{
  "priority": "HIGH",
  "score": 72,
  "confidence": 0.81,
  "trend": "INCREASING",
  "reasons": [
    "Fear-related response",
    "Sleep difficulty reported",
    "Threat-related statement"
  ],
  "requires_human_review": true,
  "last_assessed_at": "2026-09-10T15:00:00Z",
  "ai_provider": "mock"
}
```

---

### Alerts

```
GET    /alerts                     List alerts (filtered by role)
GET    /alerts/{id}                Get alert details
POST   /alerts/{id}/acknowledge    Acknowledge an alert
POST   /alerts/{id}/assign         Assign alert to counsellor
```

---

### Interventions

```
GET    /cases/{id}/interventions   List interventions
POST   /cases/{id}/interventions   Create intervention
PATCH  /interventions/{id}         Update intervention status
```

---

### Dashboard

```
GET    /dashboard/counsellor       Counsellor dashboard data
GET    /dashboard/district         District overview data
GET    /dashboard/state            State aggregate data
```

#### GET /dashboard/counsellor

**Response (200):**
```json
{
  "summary": {
    "total_cases": 42,
    "urgent": 3,
    "high": 7,
    "moderate": 18,
    "low": 14,
    "pending_alerts": 5,
    "pending_interventions": 8
  },
  "priority_cases": [
    {
      "case_number": "CASE-001042",
      "priority": "URGENT",
      "score": 88,
      "trend": "INCREASING",
      "last_checkin": "2026-09-10T12:00:00Z",
      "unacknowledged_alerts": 2
    }
  ],
  "recent_alerts": []
}
```

---

## Pagination

All list endpoints support:

```
GET /cases?page=1&page_size=20&sort_by=created_at&sort_order=desc
```

**Response wrapper:**
```json
{
  "items": [],
  "total": 100,
  "page": 1,
  "page_size": 20,
  "total_pages": 5
}
```

## Rate Limiting

| Endpoint Category | Rate Limit        |
|-------------------|-------------------|
| Auth              | 10 req/min        |
| Check-in submit   | 30 req/hour       |
| Conversation msg  | 60 req/min        |
| Voice upload      | 10 req/hour       |
| Dashboard         | 30 req/min        |
| Other             | 100 req/min       |

Rate limit headers:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1694361600
```
