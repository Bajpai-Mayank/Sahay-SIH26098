from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class AlertBase(BaseModel):
    case_id: str
    assessment_id: Optional[str] = None
    alert_type: str = "priority_change"  # priority_change, safety_cue, missed_checkin, trend_alert
    severity: str = "WARNING"  # INFO, WARNING, CRITICAL
    title: str
    description: str


class AlertCreate(AlertBase):
    pass


class AlertAcknowledge(BaseModel):
    notes: Optional[str] = None


class AlertAssign(BaseModel):
    assigned_to: str


class AlertRead(AlertBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    status: str  # pending, acknowledged, assigned, resolved, dismissed
    acknowledged_by: Optional[str] = None
    acknowledged_at: Optional[datetime] = None
    assigned_to: Optional[str] = None
    created_at: datetime
    updated_at: datetime
