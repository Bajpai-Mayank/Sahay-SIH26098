import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.config import get_settings
from app.db.session import engine
from app.db.base import Base
# Import all models to ensure metadata registration
import app.models  # noqa: F401
from app.api.v1.router import api_v1_router
from app.api.v1.health import router as root_health_router
from app.middleware.request_id import RequestIDMiddleware
from app.middleware.rate_limit import RateLimitMiddleware

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] [%(name)s] %(message)s",
)
logger = logging.getLogger("sahay.main")
settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Initializing SAHAY-AI Backend...")
    logger.info(f"Environment: {settings.APP_ENV} | Debug: {settings.DEBUG}")
    logger.info(f"AI Provider: {settings.AI_PROVIDER} (fallback: {settings.AI_FALLBACK_TO_MOCK})")
    logger.info(f"Storage Backend: {settings.STORAGE_BACKEND}")

    # Auto-create tables for local sqlite / dev environment if engine supports it
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        logger.info("Database schema initialized successfully.")
    except Exception as e:
        logger.warning(f"Database schema auto-creation notice: {e}")

    yield

    logger.info("Shutting down SAHAY-AI Backend...")
    await engine.dispose()


app = FastAPI(
    title="SAHAY-AI Backend API",
    description=(
        "Research and practice-grade AI-assisted victim well-being monitoring "
        "and early-support platform backend (SIH26094 concept)."
    ),
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

# Request ID tracing middleware (innermost to outermost)
app.add_middleware(RateLimitMiddleware, max_requests=120, window_seconds=60)
app.add_middleware(RequestIDMiddleware)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Exception handler for unhandled exceptions
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    req_id = getattr(request.state, "request_id", "unknown")
    logger.error(f"Unhandled exception [Request ID: {req_id}]: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "message": "An internal server error occurred.",
            "request_id": req_id,
            "detail": str(exc) if settings.DEBUG else None,
        },
    )

# Include root health routes and API v1 routes
app.include_router(root_health_router)  # /health, /health/db, /health/dependencies
app.include_router(api_v1_router)       # /api/v1/...


@app.get("/")
async def root():
    return {
        "app": settings.APP_NAME,
        "version": "1.0.0",
        "docs": "/docs",
        "api_v1": "/api/v1",
        "status": "online",
    }
