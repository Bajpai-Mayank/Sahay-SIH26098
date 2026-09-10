from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, ConfigDict, Field


class CheckinCreate(BaseModel):
    checkin_type: str = "scheduled"  # scheduled, on_demand, follow_up
    responses: Dict[str, Any] = Field(default_factory=dict)
    mood_rating: Optional[int] = Field(None, ge=1, le=5)
    distress_level: Optional[int] = Field(None, ge=1, le=10)
    notes: Optional[str] = None
    idempotency_key: str = Field(..., min_length=8, max_length=64)


class CheckinRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    case_id: str
    checkin_type: str
    responses: Dict[str, Any]
    mood_rating: Optional[int] = None
    distress_level: Optional[int] = None
    notes: Optional[str] = None
    idempotency_key: str
    submitted_at: datetime
    created_at: datetime
    updated_at: datetime


class CheckinTrendItem(BaseModel):
    date: str
    mood_rating: Optional[int] = None
    distress_level: Optional[int] = None
    priority_level: Optional[str] = None
