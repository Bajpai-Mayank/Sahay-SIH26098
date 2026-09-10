from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.models.user import User
from app.schemas.dashboard import (
    CounsellorDashboardResponse,
    DistrictDashboardResponse,
    StateDashboardResponse,
)
from app.services.dashboard_service import DashboardService
from app.security.rbac import get_current_user, require_role

router = APIRouter(prefix="/dashboard", tags=["Dashboards"])


@router.get("/counsellor", response_model=CounsellorDashboardResponse)
async def get_counsellor_dashboard(
    current_user: User = Depends(require_role("COUNSELLOR", "DISTRICT_ADMIN", "STATE_ADMIN", "NATIONAL_ADMIN")),
    db: AsyncSession = Depends(get_db),
):
    service = DashboardService(db)
    return await service.get_counsellor_dashboard(str(current_user.id))


@router.get("/district", response_model=DistrictDashboardResponse)
async def get_district_dashboard(
    current_user: User = Depends(require_role("DISTRICT_ADMIN", "STATE_ADMIN", "NATIONAL_ADMIN")),
    db: AsyncSession = Depends(get_db),
):
    service = DashboardService(db)
    district_name = current_user.district or "Central Administrative Zone"
    return await service.get_district_dashboard(district_name)


@router.get("/state", response_model=StateDashboardResponse)
async def get_state_dashboard(
    current_user: User = Depends(require_role("STATE_ADMIN", "NATIONAL_ADMIN")),
    db: AsyncSession = Depends(get_db),
):
    service = DashboardService(db)
    state_name = current_user.state or "Delhi NCR"
    return await service.get_state_dashboard(state_name)
