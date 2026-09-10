from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, ConfigDict, EmailStr


class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    phone_number: Optional[str] = None
    district: Optional[str] = None
    state: Optional[str] = None


class UserCreate(UserBase):
    password: str
    roles: List[str] = ["VICTIM"]


class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    phone_number: Optional[str] = None
    district: Optional[str] = None
    state: Optional[str] = None
    is_active: Optional[bool] = None


class UserRead(UserBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    is_active: bool
    is_verified: bool
    roles: List[str]
    created_at: datetime
    updated_at: datetime


class UserPreferences(BaseModel):
    preferred_language: str = "en"
    notifications_enabled: bool = True
    sms_alerts_enabled: bool = False
    extra: Dict[str, Any] = {}
