from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict


class CaseAssignmentRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    case_id: str
    counsellor_id: str
    assigned_at: datetime
    unassigned_at: Optional[datetime] = None
    is_primary: bool


class CaseBase(BaseModel):
    case_number: str
    victim_id: str
    status: str = "active"  # active, monitoring, closed, archived
    district: Optional[str] = None
    state: Optional[str] = None


class CaseCreate(CaseBase):
    pass


class CaseUpdate(BaseModel):
    status: Optional[str] = None
    district: Optional[str] = None
    state: Optional[str] = None
    closed_at: Optional[datetime] = None


class CaseRead(CaseBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    closed_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    assignments: List[CaseAssignmentRead] = []


class CaseTimelineItem(BaseModel):
    id: str
    timestamp: datetime
    event_type: str  # checkin, assessment, priority_change, alert, intervention
    title: str
    description: Optional[str] = None
    metadata: dict = {}


class SupportPrioritySummary(BaseModel):
    case_id: str
    current_level: str  # LOW, MODERATE, HIGH, URGENT
    current_score: float
    reasons: List[str]
    requires_human_review: bool
    last_updated: datetime
