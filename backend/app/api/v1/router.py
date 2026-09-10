from fastapi import APIRouter

from app.api.v1.health import router as health_router
from app.api.v1.auth import router as auth_router
from app.api.v1.users import router as users_router
from app.api.v1.cases import router as cases_router
from app.api.v1.conversations import router as conversations_router
from app.api.v1.alerts import router as alerts_router
from app.api.v1.interventions import router as interventions_router
from app.api.v1.voice import router as voice_router
from app.api.v1.dashboards import router as dashboards_router

api_v1_router = APIRouter(prefix="/api/v1")

api_v1_router.include_router(health_router)
api_v1_router.include_router(auth_router)
api_v1_router.include_router(users_router)
api_v1_router.include_router(cases_router)
api_v1_router.include_router(conversations_router)
api_v1_router.include_router(alerts_router)
api_v1_router.include_router(interventions_router)
api_v1_router.include_router(voice_router)
api_v1_router.include_router(dashboards_router)
