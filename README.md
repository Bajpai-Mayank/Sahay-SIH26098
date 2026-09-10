# SAHAY-AI

**SAHAY-AI** is a practice/research-grade AI-assisted victim well-being monitoring and early-support platform based on the SIH26094 concept.

> **Disclaimer:** This is NOT a production government application and NOT a clinical diagnostic system. It is an end-to-end engineering and research platform designed to study human-in-the-loop workflows, responsible AI boundaries, and resilient cross-platform system architecture.

---

## System Architecture Overview

```text
Flutter (Web / Android / Windows)
    │
 HTTPS REST API (/api/v1)
    │
FastAPI Backend
    ├── Authentication / RBAC (Victim, Counsellor, District Admin, State Admin)
    ├── Case & Consent Management
    ├── Check-in & Timeline Processing
    ├── Deterministic Safety Engine & Triage
    ├── Support Priority Classification
    ├── Counsellor Alert & Intervention Management
    ├── Multi-Provider AI Orchestration (Mock / Ollama / Gemini / HuggingFace)
    └── PostgreSQL + Redis + Object Storage
```

---

## Repository Structure

- `frontend/`: Cross-platform Flutter client organized by features (Riverpod, GoRouter, Dio).
- `backend/`: Python FastAPI service organized in clean layers (API, Service, Repository, AI Provider abstraction).
- `docs/`: System documentation, data dictionary, AI safety boundaries, API specifications, and architecture decision records.

---

## Getting Started

### Documentation
See [docs/README.md](file:///d:/Sahay/docs/README.md) and [docs/ARCHITECTURE.md](file:///d:/Sahay/docs/ARCHITECTURE.md) for full architectural blueprints.

### Flutter Client
```bash
cd frontend
flutter pub get
flutter run
```

### Backend (Phase 3+)
```bash
cd backend
python -m venv venv
# activate venv
pip install -r requirements.txt
uvicorn app.main:app --reload
```
