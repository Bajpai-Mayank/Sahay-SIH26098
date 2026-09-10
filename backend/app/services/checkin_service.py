from typing import Any, Dict, List, Optional
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.checkin import Checkin
from app.models.assessment import Assessment
from app.services.support_priority_service import SupportPriorityService


class CheckinService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.priority_service = SupportPriorityService(db)

    async def submit_checkin(
        self,
        case_id: str,
        checkin_type: str,
        responses: Dict[str, Any],
        idempotency_key: str,
        mood_rating: Optional[int] = None,
        distress_level: Optional[int] = None,
        notes: Optional[str] = None,
    ) -> Checkin:
        # Check idempotency
        stmt = select(Checkin).where(Checkin.idempotency_key == idempotency_key)
        res = await self.db.execute(stmt)
        existing = res.scalar_one_or_none()
        if existing:
            return existing

        checkin = Checkin(
            case_id=case_id,
            checkin_type=checkin_type,
            responses=responses,
            idempotency_key=idempotency_key,
            mood_rating=mood_rating,
            distress_level=distress_level,
            notes=notes,
        )
        self.db.add(checkin)
        await self.db.flush()

        # Trigger automatic support priority assessment
        await self.priority_service.evaluate_and_record(case_id=case_id, checkin=checkin)

        await self.db.commit()
        await self.db.refresh(checkin)
        return checkin

    async def get_case_checkins(self, case_id: str, limit: int = 30) -> List[Checkin]:
        stmt = (
            select(Checkin)
            .where(Checkin.case_id == case_id)
            .order_by(desc(Checkin.submitted_at))
            .limit(limit)
        )
        res = await self.db.execute(stmt)
        return list(res.scalars().all())

    async def get_case_trend(self, case_id: str, limit: int = 14) -> List[Dict[str, Any]]:
        """Retrieve checkin trend data for charts."""
        stmt = (
            select(Checkin)
            .where(Checkin.case_id == case_id)
            .order_by(Checkin.submitted_at.asc())
            .limit(limit)
        )
        res = await self.db.execute(stmt)
        checkins = list(res.scalars().all())

        trend_items = []
        for c in checkins:
            trend_items.append({
                "date": c.submitted_at.strftime("%Y-%m-%d"),
                "mood_rating": c.mood_rating,
                "distress_level": c.distress_level,
            })
        return trend_items
