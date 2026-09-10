from typing import List, Optional
from datetime import datetime, timezone
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.intervention import Intervention


class InterventionService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_case_interventions(self, case_id: str) -> List[Intervention]:
        stmt = (
            select(Intervention)
            .where(Intervention.case_id == case_id)
            .order_by(desc(Intervention.created_at))
        )
        res = await self.db.execute(stmt)
        return list(res.scalars().all())

    async def create_intervention(
        self,
        case_id: str,
        created_by: str,
        intervention_type: str,
        description: str,
        priority: str = "MODERATE",
        scheduled_at: Optional[datetime] = None,
        alert_id: Optional[str] = None,
    ) -> Intervention:
        intervention = Intervention(
            case_id=case_id,
            alert_id=alert_id,
            created_by=created_by,
            intervention_type=intervention_type,
            priority=priority,
            description=description,
            scheduled_at=scheduled_at,
            status="planned",
        )
        self.db.add(intervention)
        await self.db.commit()
        await self.db.refresh(intervention)
        return intervention

    async def update_intervention(
        self,
        intervention_id: str,
        status: Optional[str] = None,
        outcome: Optional[str] = None,
        completed_at: Optional[datetime] = None,
    ) -> Optional[Intervention]:
        stmt = select(Intervention).where(Intervention.id == intervention_id)
        res = await self.db.execute(stmt)
        intervention = res.scalar_one_or_none()
        if not intervention:
            return None

        if status:
            intervention.status = status
            if status == "completed" and not completed_at:
                intervention.completed_at = datetime.now(timezone.utc)
        if outcome:
            intervention.outcome = outcome
        if completed_at:
            intervention.completed_at = completed_at

        await self.db.commit()
        await self.db.refresh(intervention)
        return intervention
