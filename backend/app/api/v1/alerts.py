from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.models.user import User
from app.schemas.alert import AlertRead, AlertAcknowledge, AlertAssign
from app.services.alert_service import AlertService
from app.security.rbac import get_current_user, require_role

router = APIRouter(prefix="/alerts", tags=["Alerts"])


@router.get("", response_model=List[AlertRead])
async def list_alerts(
    case_id: Optional[str] = None,
    severity: Optional[str] = None,
    status: Optional[str] = None,
    current_user: User = Depends(require_role("COUNSELLOR", "DISTRICT_ADMIN", "STATE_ADMIN", "NATIONAL_ADMIN")),
    db: AsyncSession = Depends(get_db),
):
    service = AlertService(db)
    return await service.get_alerts(case_id=case_id, severity=severity, status=status)


@router.get("/{alert_id}", response_model=AlertRead)
async def get_alert(
    alert_id: str,
    current_user: User = Depends(require_role("COUNSELLOR", "DISTRICT_ADMIN", "STATE_ADMIN", "NATIONAL_ADMIN")),
    db: AsyncSession = Depends(get_db),
):
    service = AlertService(db)
    alert = await service.get_alert_by_id(alert_id)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    return alert


@router.post("/{alert_id}/acknowledge", response_model=AlertRead)
async def acknowledge_alert(
    alert_id: str,
    req: AlertAcknowledge,
    current_user: User = Depends(require_role("COUNSELLOR", "DISTRICT_ADMIN", "STATE_ADMIN", "NATIONAL_ADMIN")),
    db: AsyncSession = Depends(get_db),
):
    service = AlertService(db)
    alert = await service.acknowledge_alert(alert_id, str(current_user.id))
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    return alert


@router.post("/{alert_id}/assign", response_model=AlertRead)
async def assign_alert(
    alert_id: str,
    req: AlertAssign,
    current_user: User = Depends(require_role("DISTRICT_ADMIN", "STATE_ADMIN", "NATIONAL_ADMIN")),
    db: AsyncSession = Depends(get_db),
):
    service = AlertService(db)
    alert = await service.assign_alert(alert_id, req.assigned_to)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    return alert
