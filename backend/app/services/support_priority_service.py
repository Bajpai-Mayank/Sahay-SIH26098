from typing import Any, Dict, List, Optional
from datetime import datetime, timezone
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.case import Case
from app.models.checkin import Checkin
from app.models.assessment import Assessment, AssessmentFeature, SupportPriorityEvent
from app.models.alert import Alert
from app.ai import get_ai_provider


class SupportPriorityService:
    """
    Core engine for Support Priority assessment and triage in SAHAY-AI.
    Combines deterministic rules, AI risk evaluation, safety boundaries,
    and automatic alert generation for human-in-the-loop escalation.
    """

    def __init__(self, db: AsyncSession):
        self.db = db
        self.ai_provider = get_ai_provider()

    async def evaluate_and_record(
        self,
        case_id: str,
        checkin: Optional[Checkin] = None,
        manual_override: Optional[Dict[str, Any]] = None,
    ) -> Assessment:
        """
        Evaluate case check-in and record an Assessment with explainable features,
        trend computation, snapshot event, and escalation alert if warranted.
        """
        # 1. Fetch recent assessment history for trend computation
        history_stmt = (
            select(Assessment)
            .where(Assessment.case_id == case_id)
            .order_by(desc(Assessment.created_at))
            .limit(5)
        )
        history_res = await self.db.execute(history_stmt)
        history = list(history_res.scalars().all())

        # 2. Build evaluation input
        if manual_override:
            eval_result = {
                "priority": manual_override.get("priority", "MODERATE"),
                "score": manual_override.get("score", 50),
                "confidence": 1.0,
                "reasons": manual_override.get("reasons", ["Manual clinical override by counsellor"]),
                "requires_human_review": True,
                "features": manual_override.get("features", []),
                "provider": "manual",
                "model": "counsellor_review",
            }
        elif checkin:
            checkin_data = {
                "checkin_id": checkin.id,
                "mood_rating": checkin.mood_rating,
                "distress_level": checkin.distress_level,
                "notes": checkin.notes,
                "responses": checkin.responses,
            }
            history_data = [{"score": h.score, "priority": h.priority} for h in history]
            eval_result = await self.ai_provider.evaluate_risk(checkin_data, history=history_data)
        else:
            eval_result = {
                "priority": "LOW",
                "score": 10,
                "confidence": 0.9,
                "reasons": ["Initial baseline intake"],
                "requires_human_review": False,
                "features": [],
                "provider": self.ai_provider.provider_name,
                "model": self.ai_provider.model_name,
            }

        # 3. Calculate trend compared to previous score
        if history:
            prev_score = history[0].score
            curr_score = eval_result["score"]
            if curr_score - prev_score >= 15:
                trend = "INCREASING"
            elif prev_score - curr_score >= 15:
                trend = "DECREASING"
            else:
                trend = "STABLE"
        else:
            trend = "STABLE"

        # 4. Create Assessment record
        assessment = Assessment(
            case_id=case_id,
            checkin_id=checkin.id if checkin else None,
            assessment_type="manual" if manual_override else "automated",
            priority=eval_result.get("priority", "MODERATE"),
            score=eval_result.get("score", 50),
            confidence=eval_result.get("confidence", 0.85),
            trend=trend,
            reasons=eval_result.get("reasons", []),
            requires_human_review=eval_result.get("requires_human_review", False),
            ai_provider=eval_result.get("provider", self.ai_provider.provider_name),
            ai_model=eval_result.get("model", self.ai_provider.model_name),
        )
        self.db.add(assessment)
        await self.db.flush()

        # 5. Record explainable features
        for f in eval_result.get("features", []):
            feat = AssessmentFeature(
                assessment_id=assessment.id,
                feature_name=f.get("name", "signal"),
                feature_value=float(f.get("value", 0.5)),
                source=f.get("source", "checkin"),
                evidence=f.get("evidence"),
            )
            self.db.add(feat)

        # 6. Record SupportPriorityEvent snapshot
        event = SupportPriorityEvent(
            case_id=case_id,
            assessment_id=assessment.id,
            priority=assessment.priority,
            score=assessment.score,
            trend=trend,
            snapshot={
                "score": assessment.score,
                "priority": assessment.priority,
                "reasons": assessment.reasons,
                "checkin_id": checkin.id if checkin else None,
            },
        )
        self.db.add(event)

        # 7. Escalation Alert if HIGH or URGENT
        if assessment.priority in ["HIGH", "URGENT"]:
            alert = Alert(
                case_id=case_id,
                assessment_id=assessment.id,
                alert_type="priority_change",
                severity="CRITICAL" if assessment.priority == "URGENT" else "WARNING",
                title=f"{assessment.priority} Support Priority Triggered",
                description="; ".join(assessment.reasons) or f"Support priority escalated to {assessment.priority}.",
                status="pending",
            )
            self.db.add(alert)

        await self.db.commit()
        await self.db.refresh(assessment)
        return assessment

    async def get_latest_priority(self, case_id: str) -> Optional[Dict[str, Any]]:
        """Retrieve current support priority summary for a case."""
        stmt = (
            select(Assessment)
            .options(selectinload(Assessment.features))
            .where(Assessment.case_id == case_id)
            .order_by(desc(Assessment.created_at))
            .limit(1)
        )
        res = await self.db.execute(stmt)
        assessment = res.scalar_one_or_none()
        if not assessment:
            return None

        return {
            "case_id": case_id,
            "current_level": assessment.priority,
            "current_score": float(assessment.score),
            "reasons": assessment.reasons,
            "requires_human_review": assessment.requires_human_review,
            "last_updated": assessment.created_at,
            "trend": assessment.trend,
        }
