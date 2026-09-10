# SAHAY-AI Backend Service

FastAPI-based REST API service implementing the SAHAY-AI platform core.

## Architecture

- **FastAPI**: Asynchronous Python web framework delivering `/api/v1`
- **PostgreSQL**: Relational database managing cases, consent, interactions, and events
- **Redis**: Caching, session management, and rate limiting
- **AI Orchestrator**: Multi-provider bridge with deterministic safety guardrails

Refer to [docs/ARCHITECTURE.md](file:///d:/Sahay/docs/ARCHITECTURE.md) and [docs/API.md](file:///d:/Sahay/docs/API.md) for detailed contracts.
Backend implementation will be fully realized in Phase 3.
