from datetime import datetime
from typing import Any, Dict, List, Optional
from pydantic import BaseModel, ConfigDict, Field


class MessageCreate(BaseModel):
    content: str = Field(..., min_length=1)
    message_type: str = "text"  # text, voice_transcript, system
    metadata: Optional[Dict[str, Any]] = None


class MessageRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    conversation_id: str
    sender_type: str  # user, ai, counsellor, system
    content: str
    message_type: str
    metadata_json: Optional[Dict[str, Any]] = None
    created_at: datetime


class ConversationCreate(BaseModel):
    case_id: str
    conversation_type: str = "support_chat"  # checkin_chat, support_chat, counsellor_chat


class ConversationRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    case_id: str
    conversation_type: str
    status: str  # active, closed
    started_at: datetime
    ended_at: Optional[datetime] = None
    created_at: datetime
    messages: List[MessageRead] = []
