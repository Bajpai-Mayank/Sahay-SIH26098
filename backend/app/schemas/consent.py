from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict


class ConsentBase(BaseModel):
    consent_type: str  # data_collection, voice_recording, ai_analysis
    granted: bool
    consent_version: str = "1.0"


class ConsentCreate(ConsentBase):
    pass


class ConsentUpdate(BaseModel):
    granted: bool


class ConsentRead(ConsentBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    case_id: str
    granted_at: Optional[datetime] = None
    revoked_at: Optional[datetime] = None
    ip_address: Optional[str] = None
    created_at: datetime
    updated_at: datetime
