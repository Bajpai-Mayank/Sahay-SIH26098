# SAHAY-AI — Testing Strategy

## Test Organization

```
Backend:
  backend/app/tests/
    ├── conftest.py              # Shared fixtures
    ├── unit/                    # Pure logic, no I/O
    │   ├── test_auth_service.py
    │   ├── test_safety_rules.py
    │   ├── test_support_priority.py
    │   └── test_validators.py
    ├── integration/             # Database, Redis
    │   ├── test_user_repository.py
    │   ├── test_case_repository.py
    │   └── test_assessment_flow.py
    ├── api/                     # HTTP endpoint tests
    │   ├── test_auth_endpoints.py
    │   ├── test_case_endpoints.py
    │   ├── test_checkin_endpoints.py
    │   └── test_dashboard_endpoints.py
    ├── security/                # Security-specific tests
    │   ├── test_rbac.py
    │   ├── test_token_handling.py
    │   ├── test_rate_limiting.py
    │   └── test_input_validation.py
    └── ai/                      # AI provider tests
        ├── test_mock_provider.py
        ├── test_orchestrator.py
        ├── test_safety_boundary.py
        └── test_output_validation.py

Flutter:
  frontend/test/
    ├── unit/                    # Dart logic tests
    │   ├── validators_test.dart
    │   ├── token_manager_test.dart
    │   └── models_test.dart
    ├── widget/                  # Widget tests
    │   ├── login_screen_test.dart
    │   ├── checkin_form_test.dart
    │   └── dashboard_test.dart
    └── integration/             # Integration tests
        └── app_test.dart
```

## Test Categories

### 1. Authentication Tests

| Test Case                                      | Type     |
|------------------------------------------------|----------|
| Register with valid credentials                | API      |
| Register with duplicate email                  | API      |
| Login with correct password                    | API      |
| Login with wrong password                      | API      |
| Login with non-existent user                   | API      |
| Access protected route without token           | API      |
| Access protected route with expired token      | API      |
| Refresh token rotation                         | API      |
| Refresh with revoked token                     | API      |
| Logout invalidates refresh token               | API      |
| Password meets complexity requirements         | Unit     |
| Password hash verification                     | Unit     |

### 2. RBAC Tests

| Test Case                                      | Type     |
|------------------------------------------------|----------|
| Victim can access own case                     | API      |
| Victim cannot access other's case              | API      |
| Counsellor can access assigned case            | API      |
| Counsellor cannot access unassigned case       | API      |
| District admin sees district-level data        | API      |
| State admin sees only aggregate data           | API      |
| Role escalation prevention                     | Security |

### 3. Input Validation Tests

| Test Case                                      | Type     |
|------------------------------------------------|----------|
| Empty required fields rejected                 | API      |
| Oversized input rejected                       | API      |
| SQL injection attempt rejected                 | Security |
| XSS attempt sanitized                          | Security |
| Invalid UUID format rejected                   | API      |
| Invalid enum value rejected                    | API      |
| Negative numbers where positive expected       | API      |

### 4. Duplicate Submission Tests

| Test Case                                      | Type     |
|------------------------------------------------|----------|
| Duplicate check-in with same idempotency key   | API      |
| Different check-in with different key          | API      |
| Concurrent submissions with same key           | Integration|

### 5. AI Tests

| Test Case                                      | Type     |
|------------------------------------------------|----------|
| Mock provider returns valid schema             | Unit     |
| Mock provider handles scenarios                | Unit     |
| Output always passes schema validation         | Unit     |
| Safety cues detected by deterministic rules    | Unit     |
| AI safety detection supplements rules          | Unit     |
| Malformed AI response handled gracefully       | Unit     |
| Provider timeout handled with fallback         | Integration|
| Provider unavailable triggers mock fallback    | Integration|
| Prompt injection does not alter behaviour      | Security |
| Output validation blocks prohibited phrases    | Unit     |

### 6. Safety Tests

| Test Case                                      | Type     |
|------------------------------------------------|----------|
| Safety keyword detected                        | Unit     |
| Non-safety text passes                         | Unit     |
| Multi-language safety detection                | Unit     |
| False positive rate within threshold           | AI       |
| False negative for critical content            | AI       |
| Escalation creates correct alert               | Integration|
| Response does not contain prohibited phrases   | Unit     |

### 7. Network/Failure Tests

| Test Case                                      | Type     |
|------------------------------------------------|----------|
| API timeout returns graceful error             | API      |
| Network failure shows retry option             | Widget   |
| Offline check-in saved as draft                | Widget   |
| Draft synced when online                       | Integration|
| Rate limit returns 429 with headers            | API      |

### 8. Language Tests

| Test Case                                      | Type     |
|------------------------------------------------|----------|
| Hindi text analysis                            | AI       |
| English text analysis                          | AI       |
| Mixed Hindi-English input                      | AI       |
| Language detection accuracy                    | AI       |

### 9. Widget Tests

| Test Case                                      | Type     |
|------------------------------------------------|----------|
| Login form validation                          | Widget   |
| Check-in form renders all fields               | Widget   |
| Loading state displayed                        | Widget   |
| Error state with retry                         | Widget   |
| Empty state message                            | Widget   |
| Dashboard priority cards render                | Widget   |
| Responsive layout on phone                     | Widget   |
| Responsive layout on tablet                    | Widget   |

## Testing Tools

| Tool                | Purpose                                |
|---------------------|----------------------------------------|
| pytest              | Python test runner                     |
| pytest-asyncio      | Async test support                     |
| httpx               | Async HTTP test client for FastAPI     |
| factory_boy         | Test data factories                    |
| faker               | Synthetic data generation              |
| flutter_test        | Dart/Flutter test framework            |
| mockito (dart)      | Mocking for Dart                       |
| integration_test    | Flutter integration tests              |

## Test Data

Use synthetic data only. Never use real victim information.

Test fixtures provide:
- Demo victim accounts
- Demo counsellor accounts
- Sample check-ins
- Sample conversations
- Sample assessments with various priority levels
- Sample alerts and interventions
