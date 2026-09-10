from typing import Any, Dict, List, Optional
from sqlalchemy import select, desc
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.conversation import Conversation
from app.models.message import Message
from app.ai import get_ai_provider
from app.ai.safety.rules import detect_safety_cues, validate_ai_response, SAFE_EMPATHETIC_FALLBACK


class ConversationService:
    def __init__(self, db: AsyncSession):
        self.db = db
        self.ai_provider = get_ai_provider()

    async def get_or_create_conversation(self, case_id: str, conv_type: str = "support_chat") -> Conversation:
        stmt = (
            select(Conversation)
            .options(selectinload(Conversation.messages))
            .where(Conversation.case_id == case_id, Conversation.status == "active")
            .order_by(desc(Conversation.created_at))
            .limit(1)
        )
        res = await self.db.execute(stmt)
        conv = res.scalar_one_or_none()
        if not conv:
            new_conv = Conversation(
                case_id=case_id,
                conversation_type=conv_type,
                status="active",
            )
            self.db.add(new_conv)
            await self.db.commit()

            reload_stmt = (
                select(Conversation)
                .options(selectinload(Conversation.messages))
                .where(Conversation.id == new_conv.id)
            )
            res = await self.db.execute(reload_stmt)
            conv = res.scalar_one()
        return conv

    async def send_message(
        self,
        conversation_id: str,
        content: str,
        sender_type: str = "user",
        message_type: str = "text",
        metadata: Optional[Dict[str, Any]] = None,
    ) -> Message:
        # Detect safety cues in incoming message
        has_cues, matched_cues = detect_safety_cues(content)
        meta = metadata or {}
        if has_cues:
            meta["safety_cues"] = matched_cues

        msg = Message(
            conversation_id=conversation_id,
            sender_type=sender_type,
            content=content,
            message_type=message_type,
            metadata_json=meta,
        )
        self.db.add(msg)
        await self.db.commit()
        await self.db.refresh(msg)
        return msg

    async def generate_ai_reply(self, conversation_id: str) -> Message:
        """Fetch conversation history, invoke AI provider, validate response, and save reply."""
        stmt = (
            select(Message)
            .where(Message.conversation_id == conversation_id)
            .order_by(Message.created_at.asc())
            .limit(20)
        )
        res = await self.db.execute(stmt)
        messages = list(res.scalars().all())

        formatted_msgs = [
            {"role": "user" if m.sender_type == "user" else "assistant", "content": m.content}
            for m in messages
        ]

        ai_res = await self.ai_provider.generate_response(formatted_msgs)
        content = ai_res.get("content", SAFE_EMPATHETIC_FALLBACK)

        # Enforce validation
        is_safe, violations, sanitized = validate_ai_response(content)
        final_content = sanitized if is_safe else SAFE_EMPATHETIC_FALLBACK

        reply = Message(
            conversation_id=conversation_id,
            sender_type="ai",
            content=final_content,
            message_type="text",
            metadata_json={
                "provider": ai_res.get("provider", "unknown"),
                "model": ai_res.get("model", "unknown"),
                "safety_flag": ai_res.get("safety_flag", False) or (not is_safe),
                "violations": violations,
            },
        )
        self.db.add(reply)
        await self.db.commit()
        await self.db.refresh(reply)
        return reply
