# SAHAY-AI — Decisions Log

This document tracks all significant architecture and technology decisions.

---

## DEC-001: State Management — Riverpod

**Date:** 2026-09-10
**Status:** DECIDED
**Context:** Need a consistent state management approach for Flutter.
**Options Considered:**
1. `provider` — Simpler, but limited async support and testing ergonomics
2. `riverpod` — Compile-safe, no BuildContext dependency, excellent testing
3. `bloc` — Powerful but verbose for this project size
4. `getx` — Not recommended for maintainable architectures

**Decision:** Riverpod (with code generation via `riverpod_generator`)
**Rationale:** Best balance of type safety, testability, async support, and code generation. Supports dependency injection natively. No BuildContext needed for service access.

---

## DEC-002: HTTP Client — Dio

**Date:** 2026-09-10
**Status:** DECIDED
**Context:** Need an HTTP client for Flutter API communication.
**Options:** `http`, `dio`, `chopper`
**Decision:** Dio
**Rationale:** Interceptors for auth token injection, request/response logging, retry logic. Widely adopted, well-documented.

---

## DEC-003: Routing — GoRouter

**Date:** 2026-09-10
**Status:** DECIDED
**Context:** Need declarative routing supporting deep links and web URLs.
**Decision:** GoRouter
**Rationale:** Official recommendation for Flutter web. Supports path parameters, guards, redirects, nested navigation.

---

## DEC-004: Backend ORM — SQLAlchemy (Async)

**Date:** 2026-09-10
**Status:** DECIDED
**Context:** Need an ORM for PostgreSQL with async FastAPI.
**Decision:** SQLAlchemy 2.0 with async engine (asyncpg driver)
**Rationale:** Mature, well-documented, supports complex queries, migrations via Alembic.

---

## DEC-005: Password Hashing — bcrypt

**Date:** 2026-09-10
**Status:** DECIDED
**Decision:** bcrypt via `passlib[bcrypt]`
**Rationale:** Industry standard, resistant to GPU attacks, widely audited.

---

## DEC-006: JWT Library — python-jose

**Date:** 2026-09-10
**Status:** DECIDED
**Decision:** `python-jose[cryptography]` for JWT handling
**Rationale:** Supports RS256/HS256, well-maintained, recommended in FastAPI docs.

---

## DEC-007: AI Provider Default — Mock

**Date:** 2026-09-10
**Status:** DECIDED
**Context:** System must work without external AI APIs.
**Decision:** MockProvider is the default. All other providers are opt-in via `AI_PROVIDER` env var.
**Rationale:** Development, testing, and demos must never depend on API keys or external services.

---

## DEC-008: Database Migrations — Alembic

**Date:** 2026-09-10
**Status:** DECIDED
**Decision:** Alembic with async support
**Rationale:** Standard migration tool for SQLAlchemy. Supports auto-generation, reversible migrations.

---

## DEC-009: Frontend Secure Storage — flutter_secure_storage

**Date:** 2026-09-10
**Status:** DECIDED
**Decision:** `flutter_secure_storage` for tokens and sensitive data
**Rationale:** Uses Keychain (iOS), Keystore (Android), Windows Credential Locker. Platform-appropriate secure storage.

---

## DEC-010: Support Priority Naming

**Date:** 2026-09-10
**Status:** DECIDED
**Context:** Need terminology that does not imply clinical diagnosis.
**Decision:** Use "Support Priority" with levels LOW/MODERATE/HIGH/URGENT. Never use "Mental Health Score", "Risk Score", or diagnostic language.
**Rationale:** See `AI_SAFETY_BOUNDARY.md`. This is not a clinical system.

---

## DEC-011: Structured Logging — structlog

**Date:** 2026-09-10
**Status:** DECIDED
**Decision:** `structlog` for Python backend
**Rationale:** JSON-structured logs, context binding (request IDs), easy filtering, production-ready.

---

## DEC-012: API Versioning — URL Path

**Date:** 2026-09-10
**Status:** DECIDED
**Decision:** `/api/v1/` prefix for all endpoints
**Rationale:** Simple, explicit, easy to manage multiple versions if needed.

---
