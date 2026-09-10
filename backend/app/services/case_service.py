from typing import Any, Dict, List, Optional
from datetime import datetime, timezone
import uuid
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.case import Case, CaseAssignment
from app.models.checkin import Checkin
from app.models.assessment import Assessment
from app.models.alert import Alert
from app.models.intervention import Intervention
from app.models.user import User
from app.models.role import RoleName


class CaseService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_cases(
        self,
        current_user: User,
        status: Optional[str] = None,
        district: Optional[str] = None,
        skip: int = 0,
        limit: int = 20,
    ) -> Tuple[List[Case], int]:
        user_roles = [ur.role.name for ur in current_user.roles if ur.role]

        query = select(Case).options(
            selectinload(Case.assignments).selectinload(CaseAssignment.counsellor)
        )

        if RoleName.VICTIM.value in user_roles:
            query = query.where(Case.victim_id == str(current_user.id))
        elif RoleName.COUNSELLOR.value in user_roles and not any(
            r in user_roles for r in [RoleName.DISTRICT_ADMIN.value, RoleName.STATE_ADMIN.value, RoleName.NATIONAL_ADMIN.value]
        ):
            # Counsellor sees cases assigned to them
            query = query.join(Case.assignments).where(
                CaseAssignment.counsellor_id == str(current_user.id),
                CaseAssignment.unassigned_at.is_(None),
            )
        elif RoleName.DISTRICT_ADMIN.value in user_roles and current_user.district:
            query = query.where(Case.district == current_user.district)

        if status:
            query = query.where(Case.status == status)
        if district:
            query = query.where(Case.district == district)

        # Count total
        count_res = await self.db.execute(query)
        total = len(count_res.scalars().all())

        # Paginate
        paginated_query = query.order_by(desc(Case.created_at)).offset(skip).limit(limit)
        res = await self.db.execute(paginated_query)
        return list(res.scalars().all()), total

    async def get_case_by_id(self, case_id: str) -> Optional[Case]:
        stmt = (
            select(Case)
            .options(selectinload(Case.assignments).selectinload(CaseAssignment.counsellor))
            .where(Case.id == case_id)
        )
        res = await self.db.execute(stmt)
        return res.scalar_one_or_none()

    async def create_case(
        self,
        victim_id: str,
        case_number: Optional[str] = None,
        district: Optional[str] = None,
        state: Optional[str] = None,
    ) -> Case:
        if not case_number:
            case_number = f"CASE-{datetime.now(timezone.utc).strftime('%y%m%d')}-{uuid.uuid4().hex[:4].upper()}"

        case = Case(
            case_number=case_number,
            victim_id=victim_id,
            status="active",
            district=district,
            state=state,
        )
        self.db.add(case)
        await self.db.commit()
        await self.db.refresh(case)
        return case

    async def assign_counsellor(
        self, case_id: str, counsellor_id: str, is_primary: bool = True
    ) -> CaseAssignment:
        assignment = CaseAssignment(
            case_id=case_id,
            counsellor_id=counsellor_id,
            is_primary=is_primary,
            assigned_at=datetime.now(timezone.utc),
        )
        self.db.add(assignment)
        await self.db.commit()
        await self.db.refresh(assignment)
        return assignment

    async def get_case_timeline(self, case_id: str) -> List[Dict[str, Any]]:
        """
        Aggregate chronological timeline of events for a case:
        checkins, assessments, alerts, interventions.
        """
        events: List[Dict[str, Any]] = []

        # Checkins
        ch_stmt = select(Checkin).where(Checkin.case_id == case_id).order_by(desc(Checkin.created_at)).limit(20)
        ch_res = await self.db.execute(ch_stmt)
        for ch in ch_res.scalars().all():
            events.append({
                "id": ch.id,
                "timestamp": ch.created_at,
                "event_type": "checkin",
                "title": f"Check-in ({ch.checkin_type})",
                "description": f"Mood: {ch.mood_rating or 'N/A'}/5, Distress: {ch.distress_level or 'N/A'}/10. {ch.notes or ''}",
                "metadata": {"mood_rating": ch.mood_rating, "distress_level": ch.distress_level},
            })

        # Assessments
        as_stmt = select(Assessment).where(Assessment.case_id == case_id).order_by(desc(Assessment.created_at)).limit(20)
        as_res = await self.db.execute(as_stmt)
        for a in as_res.scalars().all():
            events.append({
                "id": a.id,
                "timestamp": a.created_at,
                "event_type": "assessment",
                "title": f"Support Priority: {a.priority}",
                "description": f"Score: {a.score}/100. Trend: {a.trend}. {'; '.join(a.reasons)}",
                "metadata": {"priority": a.priority, "score": a.score, "trend": a.trend},
            })

        # Alerts
        al_stmt = select(Alert).where(Alert.case_id == case_id).order_by(desc(Alert.created_at)).limit(20)
        al_res = await self.db.execute(al_stmt)
        for al in al_res.scalars().all():
            events.append({
                "id": al.id,
                "timestamp": al.created_at,
                "event_type": "alert",
                "title": f"Alert: {al.title} ({al.severity})",
                "description": al.description,
                "metadata": {"severity": al.severity, "status": al.status},
            })

        # Interventions
        in_stmt = select(Intervention).where(Intervention.case_id == case_id).order_by(desc(Intervention.created_at)).limit(20)
        in_res = await self.db.execute(in_stmt)
        for iv in in_res.scalars().all():
            events.append({
                "id": iv.id,
                "timestamp": iv.created_at,
                "event_type": "intervention",
                "title": f"Intervention: {iv.intervention_type} ({iv.status})",
                "description": iv.description,
                "metadata": {"status": iv.status, "priority": iv.priority},
            })

        # Sort all descending by timestamp
        events.sort(key=lambda x: x["timestamp"], reverse=True)
        return events
