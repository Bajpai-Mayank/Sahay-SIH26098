from typing import List, Optional
from datetime import datetime, timezone
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.alert import Alert


class AlertService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_alerts(
        self,
        case_id: Optional[str] = None,
        severity: Optional[str] = None,
        status: Optional[str] = None,
        limit: int = 50,
    ) -> List[Alert]:
        stmt = select(Alert)
        if case_id:
            stmt = stmt.where(Alert.case_id == case_id)
        if severity:
            stmt = stmt.where(Alert.severity == severity)
        if status:
            stmt = stmt.where(Alert.status == status)

        stmt = stmt.order_by(desc(Alert.created_at)).limit(limit)
        res = await self.db.execute(stmt)
        return list(res.scalars().all())

    async def get_alert_by_id(self, alert_id: str) -> Optional[Alert]:
        stmt = select(Alert).where(Alert.id == alert_id)
        res = await self.db.execute(stmt)
        return res.scalar_one_or_none()

    async def acknowledge_alert(self, alert_id: str, acknowledged_by_user_id: str) -> Optional[Alert]:
        alert = await self.get_alert_by_id(alert_id)
        if not alert:
            return None
        alert.status = "acknowledged"
        alert.acknowledged_by = acknowledged_by_user_id
        alert.acknowledged_at = datetime.now(timezone.utc)
        await self.db.commit()
        await self.db.refresh(alert)
        return alert

    async def assign_alert(self, alert_id: str, assigned_to_user_id: str) -> Optional[Alert]:
        alert = await self.get_alert_by_id(alert_id)
        if not alert:
            return None
        alert.status = "assigned"
        alert.assigned_to = assigned_to_user_id
        await self.db.commit()
        await self.db.refresh(alert)
        return alert
