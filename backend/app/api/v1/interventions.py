from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.models.user import User
from app.schemas.intervention import InterventionRead, InterventionUpdate
from app.services.intervention_service import InterventionService
from app.security.rbac import get_current_user, require_role

router = APIRouter(prefix="/interventions", tags=["Interventions"])


@router.get("/{intervention_id}", response_model=InterventionRead)
async def get_intervention(
    intervention_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = InterventionService(db)
    # Check directly via db
    from sqlalchemy import select
    from app.models.intervention import Intervention
    res = await db.execute(select(Intervention).where(Intervention.id == intervention_id))
    item = res.scalar_one_or_none()
    if not item:
        raise HTTPException(status_code=404, detail="Intervention not found")
    return item


@router.put("/{intervention_id}", response_model=InterventionRead)
async def update_intervention(
    intervention_id: str,
    req: InterventionUpdate,
    current_user: User = Depends(require_role("COUNSELLOR", "DISTRICT_ADMIN", "STATE_ADMIN", "NATIONAL_ADMIN")),
    db: AsyncSession = Depends(get_db),
):
    service = InterventionService(db)
    item = await service.update_intervention(
        intervention_id=intervention_id,
        status=req.status,
        outcome=req.outcome,
        completed_at=req.completed_at,
    )
    if not item:
        raise HTTPException(status_code=404, detail="Intervention not found")
    return item
