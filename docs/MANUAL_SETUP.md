# SAHAY-AI — Manual Setup & Integration Resource Guide

This guide details all external services, accounts, API keys, and environment variables needed to manually configure and run **SAHAY-AI** with real cloud infrastructure (Gemini API, Supabase Database & Auth, Hugging Face, Redis, and Ollama).

---

## Quick Reference: Required Keys & Services

| Service | Purpose | Where to Get | Free Tier Available? | Env Variable Name |
| :--- | :--- | :--- | :--- | :--- |
| **Google Gemini API** | Multilingual chat, text analysis, sentiment & structured signal extraction | [Google AI Studio](https://aistudio.google.com/) | ✅ Yes (Generous free tier) | `GEMINI_API_KEY` |
| **Supabase Database** | Managed PostgreSQL (17 relational tables, indexes, audit logs) | [Supabase Dashboard](https://supabase.com/dashboard) | ✅ Yes (2 free projects, 500MB DB) | `DATABASE_URL` |
| **Supabase Auth & JWT** | User authentication, password hashing, and token issuance | [Supabase Project Settings > API](https://supabase.com/dashboard) | ✅ Yes (50,000 monthly active users) | `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_JWT_SECRET` |
| **Supabase Storage** | S3-compatible audio asset storage for optional voice check-ins | [Supabase Storage](https://supabase.com/dashboard) | ✅ Yes (1GB free storage) | `STORAGE_BACKEND=supabase`, `SUPABASE_SERVICE_ROLE_KEY` |
| **Upstash Redis** | Sliding-window rate limiting, cache, token revocation blacklist | [Upstash Console](https://console.upstash.com/) | ✅ Yes (10,000 commands/day free) | `REDIS_URL` |
| **Hugging Face** | Specialized NLP models, Indic language embeddings, sentiment | [Hugging Face Settings](https://huggingface.co/settings/tokens) | ✅ Yes (Free user access token) | `HF_TOKEN` |
| **Ollama (Optional Local AI)** | Completely offline, zero-cost private LLM inference (Gemma 2, Qwen 2.5) | [Ollama Website](https://ollama.com/) | ✅ 100% Free & Local | `OLLAMA_BASE_URL=http://localhost:11434` |

---

## 1. Google Gemini API Setup

### What it Powers
- Natural language check-in conversations.
- Emotion, affect, and distress signal extraction.
- Structured summarization for caseworker review (under AI Safety Boundary rules).

### Step-by-Step Setup
1. Go to **[Google AI Studio](https://aistudio.google.com/)**.
2. Sign in with your Google account.
3. Click **"Get API key"** in the top navigation bar.
4. Click **"Create API key in new project"** (or select an existing Google Cloud project).
5. Copy the generated API key (format: `AIzaSy...`).
6. Recommended Models:
   - `gemini-1.5-flash`: Best balance of speed, cost, and multilingual Indic support.
   - `gemini-1.5-pro`: Complex multi-turn analysis.

### Environment Variable
```env
AI_PROVIDER=gemini
AI_MODEL=gemini-1.5-flash
GEMINI_API_KEY=AIzaSyYourGeneratedGeminiApiKeyHere
```

> ⚠️ **CRITICAL:** Never expose this key to the Flutter frontend. All Gemini requests are orchestrated strictly through the FastAPI backend (`backend/app/ai/providers/gemini.py`).

---

## 2. Supabase Setup (Database, Auth, and Storage)

Supabase provides an integrated solution delivering:
1. **Managed PostgreSQL** (directly compatible with our SQLAlchemy & Alembic schema).
2. **Built-in Authentication** (JWT handling, password hashing, and user management).
3. **Object Storage** (for optional voice recordings).

### Step-by-Step Setup

#### A. Create a Supabase Project
1. Visit **[supabase.com](https://supabase.com/)** and sign in / sign up.
2. Click **"New project"**.
3. Fill in project details:
   - **Name:** `sahay-ai-core`
   - **Database Password:** Choose a strong password (save this securely!).
   - **Region:** Select `South Asia (Mumbai)` or the region closest to you for minimal latency.
   - **Pricing Plan:** Free tier.
4. Click **"Create new project"** (takes ~1-2 minutes to provision).

#### B. Retrieve Connection Credentials
Navigate to **Project Settings (gear icon) > API**:
- **Project URL:** e.g., `https://abcdefghijklm.supabase.co`
- **Project API Keys:**
  - `anon` `public`: Safe for client use (e.g. Flutter app).
  - `service_role` `secret`: Backend admin privileges (bypasses Row Level Security — for FastAPI backend only).
- **JWT Settings:**
  - `JWT Secret`: Copy this string. It is used by FastAPI to verify Supabase JWT tokens.

#### C. Retrieve PostgreSQL Connection String
Navigate to **Project Settings > Database > Connection string**:
- Select the **URI** tab.
- Choose **Mode: Transaction** (Port `6543` for connection pooling) or **Session** (Port `5432`).
- The connection string will look like:
  ```text
  postgresql://postgres.[YOUR-PROJECT-REF]:[YOUR-PASSWORD]@aws-0-ap-south-1.pooler.supabase.com:6543/postgres
  ```
- For Python async SQLAlchemy (`asyncpg`), prefix with `postgresql+asyncpg://`:
  ```text
  postgresql+asyncpg://postgres.[YOUR-PROJECT-REF]:[YOUR-PASSWORD]@aws-0-ap-south-1.pooler.supabase.com:6543/postgres
  ```

#### D. Create Audio Storage Bucket
1. In the Supabase sidebar, click **Storage**.
2. Click **"New bucket"**.
3. **Name:** `audio-checkins`
4. **Public bucket:** ❌ **DISABLED (Private)** — Audio files must remain confidential and accessible only via signed URLs or caseworker authorization.
5. Set file size limit (e.g., `10MB`) and allowed MIME types (`audio/wav`, `audio/mpeg`, `audio/webm`).

### Environment Variables for Supabase
```env
# Database Connection (Supabase PostgreSQL via transaction pooler)
DATABASE_URL=postgresql+asyncpg://postgres.[PROJECT_REF]:[PASSWORD]@aws-0-ap-south-1.pooler.supabase.com:6543/postgres

# Supabase Project Credentials
SUPABASE_URL=https://[PROJECT_REF].supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_JWT_SECRET=your-supabase-jwt-secret-string

# Storage Settings
STORAGE_BACKEND=supabase
STORAGE_BUCKET=audio-checkins
```

---

## 3. Redis Setup (Upstash Serverless or Local)

Redis is required for:
- Sliding-window rate limiting (`10 req/min` for auth, `60 req/min` for chat).
- Blacklisting revoked JWT refresh tokens.
- Ephemeral check-in sync state.

### Option A: Cloud Serverless (Upstash — Recommended for Demo)
1. Go to **[upstash.com](https://upstash.com/)** and sign up.
2. Click **"Create Database"**.
3. **Name:** `sahay-redis`
4. **Region:** `ap-south-1 (Mumbai)`
5. Click **"Create"**.
6. Under **Connect Details**, copy the **`REDIS_URL`** (format: `rediss://default:password@endpoint.upstash.io:6379`).

### Option B: Local Redis (Docker or Native)
Run locally using Docker:
```bash
docker run -d --name sahay-redis -p 6379:6379 redis:7-alpine
```
URL:
```env
REDIS_URL=redis://localhost:6379/0
```

---

## 4. Hugging Face Setup (Optional NLP & Indic Models)

### What it Powers
- Specialized Indic NLP models (IndicBERT, IndicTrans2 for Hindi translation).
- Acoustic and speech sentiment pipelines (Wav2Vec2, SpeechBrain).

### Step-by-Step Setup
1. Go to **[huggingface.co](https://huggingface.co/)** and create a free account.
2. Go to **Settings > Access Tokens** (`https://huggingface.co/settings/tokens`).
3. Click **"New token"**.
4. **Type:** `Read`.
5. **Name:** `sahay-ai-research`.
6. Copy the token (starts with `hf_...`).

### Environment Variable
```env
HF_TOKEN=hf_YourHuggingFaceTokenHere
```

---

## 5. Ollama Setup (Local Offline AI — No API Keys Needed)

### What it Powers
Allows SAHAY-AI to run **100% locally and privately without internet access or API fees**, ideal for sensitive research deployments.

### Step-by-Step Setup
1. Download Ollama from **[ollama.com](https://ollama.com/download)**.
2. Install and launch Ollama on your machine.
3. Open a terminal and pull the recommended lightweight models:
   ```bash
   # Multilingual model with strong Hindi support:
   ollama pull qwen2.5:7b
   
   # Or ultra-fast lightweight model:
   ollama pull gemma2:2b
   ```
4. Verify Ollama is running:
   ```bash
   curl http://localhost:11434/api/version
   ```

### Environment Variable
```env
AI_PROVIDER=ollama
AI_MODEL=qwen2.5:7b
OLLAMA_BASE_URL=http://localhost:11434
```

---

## Complete `.env` File Template

Create `backend/.env` by copying this template and inserting your credentials:

```env
# ==========================================
# SAHAY-AI Production / Development .env
# ==========================================

# Core Application Settings
APP_NAME=SAHAY-AI
APP_ENV=development
DEBUG=true
PORT=8000
HOST=0.0.0.0
CORS_ORIGINS=http://localhost:3000,http://localhost:8080,http://localhost:5000,http://127.0.0.1:8000

# Database: Supabase PostgreSQL (or local PG)
DATABASE_URL=postgresql+asyncpg://postgres.[PROJECT_REF]:[PASSWORD]@aws-0-ap-south-1.pooler.supabase.com:6543/postgres

# Redis: Upstash (or local Redis)
REDIS_URL=rediss://default:[PASSWORD]@[ENDPOINT].upstash.io:6379

# Supabase Auth & Storage Credentials
SUPABASE_URL=https://[PROJECT_REF].supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsIn...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsIn...
SUPABASE_JWT_SECRET=your_jwt_secret_here

# Local JWT Fallback (if running standalone auth without Supabase)
JWT_SECRET_KEY=generate_a_random_32_byte_hex_string
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=7

# AI Orchestration
# Choose: mock | gemini | ollama | huggingface
AI_PROVIDER=gemini
AI_MODEL=gemini-1.5-flash
AI_SAFETY_STRICT=true
AI_TIMEOUT_SECONDS=30
AI_FALLBACK_TO_MOCK=true

# Google Gemini API
GEMINI_API_KEY=AIzaSy...

# Hugging Face Token (Optional)
HF_TOKEN=hf_...

# Ollama Local Server (Optional)
OLLAMA_BASE_URL=http://localhost:11434

# Storage Configuration
STORAGE_BACKEND=supabase
STORAGE_BUCKET=audio-checkins
```

---

## Manual Verification Checklist

Once you have gathered your keys, you can verify each component:

- [ ] **Gemini API:** Verify key by making a test curl request to the models list:
  ```bash
  curl "https://generativelanguage.googleapis.com/v1beta/models?key=YOUR_GEMINI_API_KEY"
  ```
- [ ] **Supabase Database:** Test database connectivity using `psql` or Database GUI (TablePlus/DBeaver):
  ```bash
  psql "postgresql://postgres.[REF]:[PASSWORD]@aws-0-ap-south-1.pooler.supabase.com:6543/postgres"
  ```
- [ ] **Supabase Storage:** Verify `audio-checkins` bucket exists and is marked **Private**.
- [ ] **Upstash Redis:** Test ping via Redis CLI or Python:
  ```python
  import redis
  r = redis.from_url("rediss://default:PASS@ENDPOINT.upstash.io:6379")
  print(r.ping()) # True
  ```
- [ ] **Mock AI Fallback:** Ensure `AI_FALLBACK_TO_MOCK=true` so the app gracefully falls back if API quotas are exceeded.
