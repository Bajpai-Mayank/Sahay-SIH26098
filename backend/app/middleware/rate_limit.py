import time
from collections import defaultdict
from typing import Dict, List, Tuple
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import JSONResponse

from app.config import get_settings

settings = get_settings()

# In-memory sliding window fallback: ip -> list of timestamps
_in_memory_requests: Dict[str, List[float]] = defaultdict(list)


class RateLimitMiddleware(BaseHTTPMiddleware):
    """
    Sliding-window rate limiter.
    Uses in-memory cache with fallback so the app functions seamlessly
    without an active Redis server.
    """

    def __init__(self, app, max_requests: int = 120, window_seconds: int = 60):
        super().__init__(app)
        self.max_requests = max_requests
        self.window_seconds = window_seconds

    async def dispatch(self, request: Request, call_next):
        # Exclude static/health/docs checks from strict rate limits
        path = request.url.path
        if path.startswith(("/docs", "/openapi.json", "/redoc", "/health", "/api/v1/health")):
            return await call_next(request)

        # Client IP
        client_ip = request.client.host if request.client else "127.0.0.1"
        now = time.time()

        # In-memory rate limiting check
        timestamps = _in_memory_requests[client_ip]
        # Keep only timestamps within window
        _in_memory_requests[client_ip] = [t for t in timestamps if now - t < self.window_seconds]

        if len(_in_memory_requests[client_ip]) >= self.max_requests:
            return JSONResponse(
                status_code=429,
                content={
                    "success": False,
                    "message": "Too many requests. Please try again shortly.",
                    "data": None,
                },
            )

        _in_memory_requests[client_ip].append(now)
        return await call_next(request)
