from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class InterventionBase(BaseModel):
    case_id: str
    alert_id: Optional[str] = None
    intervention_type: str = "counselling_session"  # contact, follow_up, referral, counselling_session, safety_plan
    priority: str = "MODERATE"
    description: str
    scheduled_at: Optional[datetime] = None


class InterventionCreate(InterventionBase):
    pass


class InterventionUpdate(BaseModel):
    status: Optional[str] = None  # planned, in_progress, completed, cancelled
    outcome: Optional[str] = None
    completed_at: Optional[datetime] = None


class InterventionRead(InterventionBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    created_by: str
    status: str
    completed_at: Optional[datetime] = None
    outcome: Optional[str] = None
    created_at: datetime
    updated_at: datetime
