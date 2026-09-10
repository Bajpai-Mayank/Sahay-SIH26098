from datetime import datetime, timezone
from sqlalchemy import String, ForeignKey, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from ..db.base import Base


class Conversation(Base):
    __tablename__ = "conversations"

    case_id: Mapped[str] = mapped_column(String(36), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False, index=True)
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    ended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    conversation_type: Mapped[str] = mapped_column(String(20), default="support_chat", nullable=False)  # checkin_chat, support_chat, counsellor_chat
    status: Mapped[str] = mapped_column(String(20), default="active", nullable=False)  # active, closed

    case: Mapped["Case"] = relationship("Case", back_populates="conversations")
    messages: Mapped[list["Message"]] = relationship("Message", back_populates="conversation", cascade="all, delete-orphan")
