from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, ConfigDict, Field


class AssessmentFeatureRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    feature_name: str
    feature_value: float
    source: str
    evidence: Optional[str] = None


class SupportPriorityEventRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    case_id: str
    assessment_id: str
    priority: str
    score: int
    trend: str
    snapshot: Dict[str, Any]
    created_at: datetime


class AssessmentRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    case_id: str
    checkin_id: Optional[str] = None
    assessment_type: str
    priority: str  # LOW, MODERATE, HIGH, URGENT
    score: int  # 0 to 100
    confidence: float
    trend: str
    reasons: List[str]
    requires_human_review: bool
    ai_provider: str
    ai_model: Optional[str] = None
    reviewed_by: Optional[str] = None
    reviewed_at: Optional[datetime] = None
    created_at: datetime
    features: List[AssessmentFeatureRead] = []


class AssessmentCreateManual(BaseModel):
    case_id: str
    priority: str = Field(..., description="LOW, MODERATE, HIGH, URGENT")
    score: int = Field(..., ge=0, le=100)
    reasons: List[str] = Field(default_factory=list)
    notes: Optional[str] = None
