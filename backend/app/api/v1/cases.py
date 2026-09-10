from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.db.session import get_db
from app.models.user import User
from app.models.case import Case, CaseAssignment
from app.models.consent import Consent
from app.models.checkin import Checkin
from app.models.assessment import Assessment
from app.models.intervention import Intervention
from app.schemas.case import CaseRead, CaseCreate, CaseUpdate, CaseTimelineItem, SupportPrioritySummary
from app.schemas.consent import ConsentRead, ConsentCreate
from app.schemas.checkin import CheckinRead, CheckinCreate, CheckinTrendItem
from app.schemas.assessment import AssessmentRead, AssessmentCreateManual
from app.schemas.intervention import InterventionRead, InterventionCreate
from app.services.case_service import CaseService
from app.services.checkin_service import CheckinService
from app.services.support_priority_service import SupportPriorityService
from app.services.intervention_service import InterventionService
from app.security.rbac import get_current_user, require_role, check_case_access

router = APIRouter(prefix="/cases", tags=["Cases"])


@router.get("", response_model=List[CaseRead])
async def list_cases(
    status: Optional[str] = None,
    district: Optional[str] = None,
    page: int = 1,
    page_size: int = 20,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = CaseService(db)
    skip = (page - 1) * page_size
    cases, _ = await service.get_cases(current_user, status=status, district=district, skip=skip, limit=page_size)
    return cases


@router.post("", response_model=CaseRead)
async def create_case(
    req: CaseCreate,
    current_user: User = Depends(require_role("COUNSELLOR", "DISTRICT_ADMIN", "STATE_ADMIN", "NATIONAL_ADMIN")),
    db: AsyncSession = Depends(get_db),
):
    service = CaseService(db)
    return await service.create_case(
        victim_id=req.victim_id,
        case_number=req.case_number,
        district=req.district,
        state=req.state,
    )


@router.get("/{case_id}", response_model=CaseRead)
async def get_case(
    case_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = CaseService(db)
    case = await service.get_case_by_id(case_id)
    if not case:
        raise HTTPException(status_code=404, detail="Case not found")
    
    # Check object level access
    if not await check_case_access(case.id, current_user, db):
        raise HTTPException(status_code=403, detail="Access denied to this case")
    return case


@router.get("/{case_id}/consent", response_model=List[ConsentRead])
async def get_consent(
    case_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    stmt = select(Consent).where(Consent.case_id == case_id)
    res = await db.execute(stmt)
    return list(res.scalars().all())


@router.post("/{case_id}/consent", response_model=ConsentRead)
async def create_consent(
    case_id: str,
    req: ConsentCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    consent = Consent(
        case_id=case_id,
        consent_type=req.consent_type,
        granted=req.granted,
        consent_version=req.consent_version,
    )
    db.add(consent)
    await db.commit()
    await db.refresh(consent)
    return consent


@router.get("/{case_id}/checkins", response_model=List[CheckinRead])
async def get_checkins(
    case_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = CheckinService(db)
    return await service.get_case_checkins(case_id)


@router.post("/{case_id}/checkins", response_model=CheckinRead)
async def submit_checkin(
    case_id: str,
    req: CheckinCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = CheckinService(db)
    return await service.submit_checkin(
        case_id=case_id,
        checkin_type=req.checkin_type,
        responses=req.responses,
        idempotency_key=req.idempotency_key,
        mood_rating=req.mood_rating,
        distress_level=req.distress_level,
        notes=req.notes,
    )


@router.get("/{case_id}/timeline", response_model=List[CaseTimelineItem])
async def get_timeline(
    case_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = CaseService(db)
    return await service.get_case_timeline(case_id)


@router.get("/{case_id}/support-priority", response_model=SupportPrioritySummary)
async def get_support_priority(
    case_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = SupportPriorityService(db)
    summary = await service.get_latest_priority(case_id)
    if not summary:
        raise HTTPException(status_code=404, detail="No support priority assessment found for this case")
    return summary


@router.get("/{case_id}/trend", response_model=List[CheckinTrendItem])
async def get_case_trend(
    case_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = CheckinService(db)
    return await service.get_case_trend(case_id)


@router.get("/{case_id}/assessments", response_model=List[AssessmentRead])
async def get_assessments(
    case_id: str,
    current_user: User = Depends(require_role("COUNSELLOR", "DISTRICT_ADMIN", "STATE_ADMIN", "NATIONAL_ADMIN")),
    db: AsyncSession = Depends(get_db),
):
    stmt = (
        select(Assessment)
        .options(selectinload(Assessment.features))
        .where(Assessment.case_id == case_id)
        .order_by(desc(Assessment.created_at))
    )
    res = await db.execute(stmt)
    return list(res.scalars().all())


@router.post("/{case_id}/assessments", response_model=AssessmentRead)
async def create_assessment_manual(
    case_id: str,
    req: AssessmentCreateManual,
    current_user: User = Depends(require_role("COUNSELLOR", "DISTRICT_ADMIN", "STATE_ADMIN", "NATIONAL_ADMIN")),
    db: AsyncSession = Depends(get_db),
):
    service = SupportPriorityService(db)
    assessment = await service.evaluate_and_record(
        case_id=case_id,
        manual_override={
            "priority": req.priority,
            "score": req.score,
            "reasons": req.reasons,
        },
    )
    return assessment


@router.get("/{case_id}/interventions", response_model=List[InterventionRead])
async def get_interventions(
    case_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = InterventionService(db)
    return await service.get_case_interventions(case_id)


@router.post("/{case_id}/interventions", response_model=InterventionRead)
async def create_intervention(
    case_id: str,
    req: InterventionCreate,
    current_user: User = Depends(require_role("COUNSELLOR", "DISTRICT_ADMIN", "STATE_ADMIN", "NATIONAL_ADMIN")),
    db: AsyncSession = Depends(get_db),
):
    service = InterventionService(db)
    return await service.create_intervention(
        case_id=case_id,
        created_by=str(current_user.id),
        intervention_type=req.intervention_type,
        priority=req.priority,
        description=req.description,
        scheduled_at=req.scheduled_at,
        alert_id=req.alert_id,
    )


@router.post("/{case_id}/assign")
async def assign_case(
    case_id: str,
    counsellor_id: str,
    current_user: User = Depends(require_role("DISTRICT_ADMIN", "STATE_ADMIN", "NATIONAL_ADMIN")),
    db: AsyncSession = Depends(get_db),
):
    service = CaseService(db)
    assignment = await service.assign_counsellor(case_id, counsellor_id)
    return {"success": True, "assignment_id": assignment.id}
