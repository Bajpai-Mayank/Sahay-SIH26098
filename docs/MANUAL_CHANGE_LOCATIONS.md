# SAHAY-AI — Manual Change Locations & Configuration Guide

This document is your single source of truth for **WHERE** to make manual edits in both the Backend and Frontend applications.

---

## ⚠️ Critical Security Concept: `.env` vs `.env.example`

| File | Purpose | Git Status | What Goes Inside? |
| :--- | :--- | :--- | :--- |
| **`backend/.env`** | **Active Configuration** | 🔒 **IGNORED** by Git (Never uploaded) | **YOUR REAL KEYS, Passwords, & Secrets** |
| **`backend/.env.example`** | **Public Template** | 🌐 **TRACKED** on GitHub | **Placeholders only** (e.g. `API_KEY=`) |

> [!CAUTION]
> **Why we keep `.env.example` clean**:  
> `.env.example` is pushed to your GitHub repository. If you paste real API keys or passwords into `.env.example`, they will be publicly visible on GitHub, leading to compromised accounts and revoked credentials.  
> 
> **Where to paste your credentials**:  
> Always paste your actual API keys, database passwords, and tokens into **`backend/.env`**. The backend server reads directly from `backend/.env`.

---

## 1. Backend Configuration Locations

### A. AI Providers & API Keys (Kimi K3, Gemini, Ollama, HuggingFace)
* **File to Edit**: [`backend/.env`](file:///d:/Sahay/backend/.env)
* **Underlying Code Definition**: [`backend/app/config/settings.py`](file:///d:/Sahay/backend/app/config/settings.py)
* **Provider Implementation**: [`backend/app/ai/providers/`](file:///d:/Sahay/backend/app/ai/providers/)

| Setting / Key | Location in `backend/.env` | Notes / Values |
| :--- | :--- | :--- |
| **Active Provider** | `AI_PROVIDER=kimi` | Options: `mock`, `kimi`, `gemini`, `ollama`, `huggingface` |
| **NVIDIA / Kimi API Key** | `NVIDIA_API_KEY=nvapi-...` | Paste your NVIDIA NIM key. The system automatically strips any `"Bearer "` prefix if included. |
| **NVIDIA NIM Base URL** | `NVIDIA_NIM_BASE_URL=https://integrate.api.nvidia.com/v1` | Default NVIDIA API endpoint |
| **Kimi K3 Model Name** | `KIMI_K3_MODEL=moonshotai/kimi-k3` | Default high-reasoning model |
| **Google Gemini Key** | `GEMINI_API_KEY=AIzaSy...` | For Gemini fallback or standalone use |
| **Gemini Model** | `AI_MODEL=gemini-1.5-flash` | Gemini model variant |
| **Ollama Local URL** | `OLLAMA_BASE_URL=http://localhost:11434` | For local offline LLM |
| **Hugging Face Token** | `HF_TOKEN=hf_...` | For Hugging Face Inference API |
| **Fallback to Mock** | `AI_FALLBACK_TO_MOCK=true` | If `true`, system falls back to mock logic rather than crashing if an API quota is exceeded |

---

### B. Database (Supabase PostgreSQL / Local PostgreSQL)
* **File to Edit**: [`backend/.env`](file:///d:/Sahay/backend/.env)
* **Database Connection Engine**: [`backend/app/db/session.py`](file:///d:/Sahay/backend/app/db/session.py)
* **Alembic Migration Config**: [`backend/alembic/env.py`](file:///d:/Sahay/backend/alembic/env.py)

| Database Type | Location in `backend/.env` | Example Syntax |
| :--- | :--- | :--- |
| **Direct Supabase (Port 5432)** | `DATABASE_URL=...` | `postgresql+asyncpg://postgres:[PASSWORD]@db.ooqaehsxxmzkwgizwwwc.supabase.co:5432/postgres` |
| **Supabase Pooler (Port 6543)** | `DATABASE_URL=...` | `postgresql+asyncpg://postgres.ooqaehsxxmzkwgizwwwc:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres` |
| **Local SQLite (Offline)** | `DATABASE_URL=...` | `sqlite+aiosqlite:///./sahay_dev.db` |

---

### C. Supabase Auth & Cloud Storage
* **File to Edit**: [`backend/.env`](file:///d:/Sahay/backend/.env)
* **Storage Handler**: [`backend/app/storage/supabase.py`](file:///d:/Sahay/backend/app/storage/supabase.py)

| Setting | Location in `backend/.env` | Description |
| :--- | :--- | :--- |
| **Project URL** | `SUPABASE_URL=https://ooqaehsxxmzkwgizwwwc.supabase.co` | Your Supabase project endpoint |
| **Anon Public Key** | `SUPABASE_PUBLISHABLE_KEY=eyJ...` | Public client key |
| **Service Role Secret** | `SUPABASE_SECRET_KEY=eyJ...` | Elevated backend secret |
| **Storage Backend** | `STORAGE_BACKEND=supabase` | Use `supabase` or `local` |
| **Storage Bucket** | `STORAGE_BUCKET=audio-checkins` | Target bucket name |

---

### D. Security & JWT Tokens
* **File to Edit**: [`backend/.env`](file:///d:/Sahay/backend/.env)
* **JWT Logic**: [`backend/app/security/jwt.py`](file:///d:/Sahay/backend/app/security/jwt.py)
* **Password Hashing**: [`backend/app/security/password.py`](file:///d:/Sahay/backend/app/security/password.py)

| Variable | Location in `backend/.env` | Default / Description |
| :--- | :--- | :--- |
| **JWT Secret** | `JWT_SECRET_KEY=...` | Any random 32+ character string |
| **Token Expiry** | `ACCESS_TOKEN_EXPIRE_MINUTES=60` | Access token lifespan in minutes |
| **Refresh Expiry** | `REFRESH_TOKEN_EXPIRE_DAYS=7` | Refresh token lifespan in days |

---

### E. Server Port & Host
* **File to Edit**: [`backend/.env`](file:///d:/Sahay/backend/.env)
* **FastAPI Entrypoint**: [`backend/app/main.py`](file:///d:/Sahay/backend/app/main.py)

```env
HOST=0.0.0.0
PORT=8000
CORS_ORIGINS=http://localhost:3000,http://localhost:8080,http://localhost:5000,http://127.0.0.1:8000,http://localhost:8000
```

---

## 2. Frontend Configuration Locations (Flutter)

### A. Backend API Base URL & Network Timeouts
* **Exact File to Edit**: [`frontend/lib/core/config/api_config.dart`](file:///d:/Sahay/frontend/lib/core/config/api_config.dart)
* **Line 5**:
  ```dart
  static const String baseUrl = 'http://localhost:8000/api/v1';
  ```
* **When testing on Android Emulator**:
  ```dart
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  ```
* **When testing on Chrome / Desktop**:
  ```dart
  static const String baseUrl = 'http://localhost:8000/api/v1';
  ```
* **When deploying to Production**:
  ```dart
  static const String baseUrl = 'https://your-api-domain.com/api/v1';
  ```

---

### B. Navigation Routes & Screen Mapping
* **Exact File to Edit**: [`frontend/lib/app/router.dart`](file:///d:/Sahay/frontend/lib/app/router.dart)
* Controls routes such as:
  - `/login` → `LoginScreen`
  - `/register` → `RegisterScreen`
  - `/dashboard` → `DashboardScreen`
  - `/cases` → `CaseDetailScreen`
  - `/district` → `DistrictDashboardScreen`

---

### C. Visual Theme & Palette
* **Colors**: [`frontend/lib/app/theme/app_colors.dart`](file:///d:/Sahay/frontend/lib/app/theme/app_colors.dart)
  - Primary, Secondary, Background, Card, Priority Triage colors (`priorityLow`, `priorityModerate`, `priorityHigh`, `priorityUrgent`).
* **Typography**: [`frontend/lib/app/theme/app_typography.dart`](file:///d:/Sahay/frontend/lib/app/theme/app_typography.dart)
* **Spacing & Radii**: [`frontend/lib/app/theme/app_spacing.dart`](file:///d:/Sahay/frontend/lib/app/theme/app_spacing.dart), [`frontend/lib/app/theme/app_radius.dart`](file:///d:/Sahay/frontend/lib/app/theme/app_radius.dart)

---

## 3. Quick-Action Checklist

When you receive a new credential:

1. **If it's an API Key or Database Password** (e.g. Supabase password, NVIDIA API key, Gemini key):
   👉 Open **`backend/.env`** (create it if missing by copying `.env.example`).
   👉 Paste the value next to the corresponding variable name.
   👉 Save the file.
   *(Never commit this file to Git)*.

2. **If it's changing the Backend URL in Flutter**:
   👉 Open [`frontend/lib/core/config/api_config.dart`](file:///d:/Sahay/frontend/lib/core/config/api_config.dart).
   👉 Update line 5: `static const String baseUrl = '...';`.
   👉 Save and hot-reload.

3. **If it's adding or editing a seed demo user**:
   👉 Open [`backend/app/seed/seed_data.py`](file:///d:/Sahay/backend/app/seed/seed_data.py).
   👉 Update user records in `users_data`.
   👉 Re-run: `.venv\Scripts\python.exe -m app.seed.seed_data`.
