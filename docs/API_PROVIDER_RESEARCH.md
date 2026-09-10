# SAHAY-AI — API Provider & Infrastructure Research

This document provides a comparative evaluation of cloud and local infrastructure options for **SAHAY-AI**, focusing on LLMs, managed databases, authentication, storage, and caching.

---

## 1. Managed Database & Authentication: Supabase vs Self-Hosted PostgreSQL

| Dimension | Supabase (Managed) | Self-Hosted PostgreSQL |
| :--- | :--- | :--- |
| **Relational Schema** | Full standard PostgreSQL 15+ support (Alembic compatible) | Full PostgreSQL support |
| **Authentication** | Built-in JWT, email/password, phone SMS, OAuth | Custom implementation in FastAPI |
| **Connection Pooling** | PgBouncer / Supavisor on port `6543` | Custom PgBouncer container |
| **Object Storage** | S3-compatible bucket with private ACLs | MinIO / AWS S3 |
| **Free Tier** | 2 active databases, 500MB storage, 50k MAU | None (requires VPS/Server) |
| **Integration with FastAPI**| Connect via `asyncpg` URI with SSL mode | Direct TCP connection |
| **Recommendation** | **Recommended for SIH / Research / Demo** | Recommended for high-security on-premise government deployments |

---

## 2. LLM Provider Options

### Google Gemini API
- **Pros:**
  - Excellent out-of-the-box multilingual processing across 40+ languages (especially Hindi, Marathi, Bengali).
  - High speed and low latency with `gemini-1.5-flash`.
  - Generous free tier via Google AI Studio (15 RPM, 1 million TPM, 1,500 RPD).
  - Native support for strict structured JSON schema outputs.
- **Cons:**
  - Requires cloud connectivity; cannot run in strictly air-gapped environments.
- **Integration Role:** Primary cloud provider for conversational check-ins, text extraction, and sentiment/emotion indicators.

### Ollama (Local LLM Engine)
- **Pros:**
  - 100% private and offline; zero data leaves the local machine.
  - Zero API cost; no rate limits.
  - Easy model switching via CLI (`ollama pull qwen2.5:7b`).
- **Cons:**
  - Requires dedicated GPU/RAM (8GB+ RAM for 7B models, 4GB for 2B/3B models).
- **Integration Role:** Recommended for offline environments and data-sensitive local demonstrations.

### Hugging Face Hub (Inference API / Local Transformers)
- **Pros:**
  - Access to specialized Indic NLP models like `ai4bharat/indic-bert` and `ai4bharat/indictrans2-indic-en`.
  - Research-grade sentiment and emotion classifiers (`GoEmotions`).
- **Cons:**
  - Serverless inference API has cold-start delays; dedicated endpoints incur cost.
- **Integration Role:** Supplementary model provider for specialized linguistic feature extraction.

### Mock AI Provider
- **Pros:**
  - Instant response; zero setup; zero cost.
  - 100% deterministic test scenarios (normal, elevated distress, safety-sensitive).
- **Cons:**
  - Simulated outputs only.
- **Integration Role:** Default development and CI/CD testing baseline.

---

## 3. Caching & Rate Limiting: Upstash Redis vs Local Redis

| Feature | Upstash Redis (Serverless) | Local Redis |
| :--- | :--- | :--- |
| **Protocol** | Standard `rediss://` TLS protocol | `redis://localhost:6379` |
| **Setup** | Web console (1-click database creation) | `docker run -p 6379:6379 redis` |
| **Free Tier** | 10,000 commands per day | Unlimited on local machine |
| **Best For** | Cloud deployments, serverless setups | Local development & offline demos |

---

## 4. Privacy & Cost Protection Summary

1. **Fallback Strategy:** `AI_FALLBACK_TO_MOCK=true` ensures the platform remains operational even if cloud API limits are reached.
2. **Key Security:** API keys and service tokens must remain strictly in `backend/.env`. Never bundle them into the Flutter application.
3. **Synthetic Data Policy:** All cloud testing must use synthetic participant records rather than real identifiable personal data.
