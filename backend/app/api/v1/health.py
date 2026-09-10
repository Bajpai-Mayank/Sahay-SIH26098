from datetime import datetime, timezone
import time
from typing import Any, Dict
from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.db.session import get_db
from app.ai import get_ai_provider

router = APIRouter(tags=["Health & Diagnostics"])
settings = get_settings()


@router.get("/health")
async def health():
    return {
        "status": "ok",
        "service": settings.APP_NAME,
        "environment": settings.APP_ENV,
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "ai_provider": settings.AI_PROVIDER,
        "storage_backend": settings.STORAGE_BACKEND,
    }


@router.get("/health/db")
async def health_db(db: AsyncSession = Depends(get_db)):
    start = time.time()
    try:
        await db.execute(text("SELECT 1"))
        latency_ms = round((time.time() - start) * 1000, 2)
        is_sqlite = "sqlite" in settings.DATABASE_URL
        return {
            "status": "connected",
            "dialect": "sqlite" if is_sqlite else "postgresql",
            "mode": "local_sqlite" if is_sqlite else "supabase_pgbouncer",
            "latency_ms": latency_ms,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    except Exception as e:
        return {
            "status": "error",
            "error": str(e),
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }


@router.get("/health/redis")
async def health_redis():
    if not settings.REDIS_URL and not settings.UPSTASH_REDIS_REST_URL:
        return {
            "status": "not_configured",
            "mode": "in_memory_fallback",
            "message": "Redis not configured. Operating seamlessly with in-memory sliding-window limiter.",
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }
    return {
        "status": "configured",
        "mode": "redis",
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }


@router.get("/health/dependencies")
async def health_dependencies(db: AsyncSession = Depends(get_db)):
    # Database check
    db_status = "connected"
    try:
        await db.execute(text("SELECT 1"))
    except Exception as e:
        db_status = f"error: {str(e)}"

    # AI Provider check
    ai_provider = get_ai_provider()
    ai_status = await ai_provider.health_check()

    return {
        "service": settings.APP_NAME,
        "database": {
            "status": db_status,
            "url_type": "sqlite" if "sqlite" in settings.DATABASE_URL else "postgresql",
        },
        "redis": {
            "configured": bool(settings.REDIS_URL or settings.UPSTASH_REDIS_REST_URL),
            "mode": "redis" if (settings.REDIS_URL or settings.UPSTASH_REDIS_REST_URL) else "in_memory",
        },
        "ai_provider": ai_status,
        "storage": {
            "backend": settings.STORAGE_BACKEND,
            "bucket": settings.STORAGE_BUCKET,
        },
        "timestamp": datetime.now(timezone.utc).isoformat(),
    }
