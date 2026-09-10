from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.db.session import get_db
from app.models.user import User
from app.models.conversation import Conversation
from app.models.message import Message
from app.schemas.conversation import ConversationRead, ConversationCreate, MessageRead, MessageCreate
from app.services.conversation_service import ConversationService
from app.security.rbac import get_current_user

router = APIRouter(prefix="/conversations", tags=["Conversations"])


@router.get("", response_model=List[ConversationRead])
async def list_conversations(
    case_id: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    stmt = select(Conversation).options(selectinload(Conversation.messages)).order_by(desc(Conversation.created_at))
    if case_id:
        stmt = stmt.where(Conversation.case_id == case_id)
    res = await db.execute(stmt)
    return list(res.scalars().all())


@router.post("", response_model=ConversationRead)
async def create_conversation(
    req: ConversationCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = ConversationService(db)
    conv = await service.get_or_create_conversation(req.case_id, req.conversation_type)
    return conv


@router.get("/{conversation_id}", response_model=ConversationRead)
async def get_conversation(
    conversation_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    stmt = (
        select(Conversation)
        .options(selectinload(Conversation.messages))
        .where(Conversation.id == conversation_id)
    )
    res = await db.execute(stmt)
    conv = res.scalar_one_or_none()
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found")
    return conv


@router.get("/{conversation_id}/messages", response_model=List[MessageRead])
async def get_messages(
    conversation_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    stmt = (
        select(Message)
        .where(Message.conversation_id == conversation_id)
        .order_by(Message.created_at.asc())
    )
    res = await db.execute(stmt)
    return list(res.scalars().all())


@router.post("/{conversation_id}/messages", response_model=MessageRead)
async def send_message(
    conversation_id: str,
    req: MessageCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    service = ConversationService(db)
    # Save user message
    user_msg = await service.send_message(
        conversation_id=conversation_id,
        content=req.content,
        sender_type="user",
        message_type=req.message_type,
        metadata=req.metadata,
    )

    # Generate and save AI reply
    ai_reply = await service.generate_ai_reply(conversation_id)
    return ai_reply
