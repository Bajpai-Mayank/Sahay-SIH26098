# SAHAY-AI — Backend Credential Integration Checklist

> **SECURITY NOTICE**: Never paste real secrets, database passwords, or API keys into chat or commit them to git repositories. Enter your credentials directly into `backend/.env` on your local system.

The SAHAY-AI backend is engineered to run **100% offline out-of-the-box** using mock AI providers and local SQLite storage. When you are ready to connect real cloud services, follow this checklist step by step.

---

## 1. File Setup

Create your local environment file by copying the template:
```bash
cd backend
cp .env.example .env
```
*(On Windows PowerShell: `Copy-Item .env.example .env`)*

---

## 2. Service Credentials Checklist

### A. Database (Supabase PostgreSQL / Self-Hosted PostgreSQL)
Your Supabase host: `db.ooqaehsxxmzkwgizwwwc.supabase.co`
- [ ] Set `DATABASE_URL` in `backend/.env` using your Supabase database password:
  ```env
  # Direct connection (Port 5432):
  DATABASE_URL=postgresql+asyncpg://postgres:[YOUR_PASSWORD]@db.ooqaehsxxmzkwgizwwwc.supabase.co:5432/postgres

  # Or Supabase Transaction Pooler (Port 6543 - recommended if direct connection is blocked by IPv6):
  # DATABASE_URL=postgresql+asyncpg://postgres.ooqaehsxxmzkwgizwwwc:[YOUR_PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
  ```
  *(Note: `asyncpg` prepared statement cache is already configured to 0 in `app/db/session.py` to support PgBouncer transaction mode).*
- [ ] **Verification**:
  ```bash
  .venv\Scripts\python.exe -c "import asyncio; from app.db.session import engine, test_connection; asyncio.run(test_connection())"
  ```
  Or start the server and query `GET /health/db`.

---

### B. Supabase Auth & Storage (Optional)
- [ ] Your Supabase Project URL:
  ```env
  SUPABASE_URL=https://ooqaehsxxmzkwgizwwwc.supabase.co
  ```
- [ ] From Supabase Dashboard → **Project Settings** → **API**:
  - Copy **anon public** key and paste into `SUPABASE_PUBLISHABLE_KEY`:
    ```env
    SUPABASE_PUBLISHABLE_KEY=eyJhbGciOi...
    ```
  - Copy **service_role** secret and paste into `SUPABASE_SECRET_KEY`:
    ```env
    SUPABASE_SECRET_KEY=eyJhbGciOi...
    ```
- [ ] If using Supabase Storage for audio recordings, set:
  ```env
  STORAGE_BACKEND=supabase
  STORAGE_BUCKET=audio-checkins
  ```
  Create the `audio-checkins` bucket in Supabase Dashboard → **Storage**.

---

### C. AI Providers

#### Option 1: Kimi K3 via NVIDIA NIM (High Performance & Reasoning)
- [ ] Obtain an API key from [NVIDIA Build / NIM](https://build.nvidia.com/).
- [ ] Set in `backend/.env`:
  ```env
  AI_PROVIDER=kimi
  NVIDIA_API_KEY=nvapi-...
  NVIDIA_NIM_BASE_URL=https://integrate.api.nvidia.com/v1
  KIMI_K3_MODEL=moonshotai/kimi-k3
  ```
- [ ] Features full async FastAPI endpoint support + synchronous `provider.chat(msg)` method with automatic safety boundary validation.
- [ ] Leave `AI_FALLBACK_TO_MOCK=true` so that if API quotas are exceeded, the system automatically falls back to deterministic mock logic without failing requests.

#### Option 2: Google Gemini (Recommended Cloud LLM)
- [ ] Obtain an API key from [Google AI Studio](https://aistudio.google.com/).
- [ ] Set in `backend/.env`:
  ```env
  AI_PROVIDER=gemini
  AI_MODEL=gemini-1.5-flash
  GEMINI_API_KEY=AIzaSy...
  ```
- [ ] Leave `AI_FALLBACK_TO_MOCK=true` so that if API quotas are exceeded, the system automatically falls back to deterministic mock logic without failing requests.
- [ ] **Verification**: Run `GET /health/dependencies` or `GET /api/v1/health` after starting the server.

#### Option 3: Ollama (Local LLM — 100% Private, Zero Cloud Cost)
- [ ] Install [Ollama](https://ollama.com/) locally and run `ollama run llama3`.
- [ ] Set in `backend/.env`:
  ```env
  AI_PROVIDER=ollama
  OLLAMA_BASE_URL=http://localhost:11434
  ```

#### Option 4: Hugging Face Inference API
- [ ] Generate an Access Token at [Hugging Face Settings](https://huggingface.co/settings/tokens).
- [ ] Set in `backend/.env`:
  ```env
  AI_PROVIDER=huggingface
  HF_TOKEN=hf_...
  ```

#### Option 5: Mock Provider (Default)
- [ ] Set in `backend/.env`:
  ```env
  AI_PROVIDER=mock
  ```
  Requires zero API keys and runs completely offline.
  Requires zero API keys and runs completely offline.

---

### D. Redis / Upstash Cache & Rate Limiting (Optional)
- [ ] If using Upstash or Redis, set:
  ```env
  REDIS_URL=rediss://default:[TOKEN]@[ENDPOINT].upstash.io:6379
  ```
- [ ] If left unset, the backend automatically operates with the built-in in-memory sliding-window limiter.

---

## 3. Applying Database Migrations & Seeding

1. Run Alembic migrations to create tables in your connected database:
   ```bash
   .venv\Scripts\alembic.exe upgrade head
   ```
2. Seed initial synthetic roles, demo accounts, and `CASE-1042`:
   ```bash
   .venv\Scripts\python.exe -m app.seed.seed_data
   ```

---

## 4. Starting the Server

```bash
.venv\Scripts\uvicorn.exe app.main:app --host 0.0.0.0 --port 8000 --reload
```
Interactive documentation will be available at:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **System Health**: http://localhost:8000/health
- **Dependencies Diagnostics**: http://localhost:8000/health/dependencies
