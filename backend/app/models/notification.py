from sqlalchemy import String, Text, Boolean, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from ..db.base import Base


class Notification(Base):
    __tablename__ = "notifications"

    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    body: Mapped[str] = mapped_column(Text, nullable=False)
    notification_type: Mapped[str] = mapped_column(String(30), default="update", nullable=False)  # alert, reminder, update, system
    is_read: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False, index=True)
    reference_type: Mapped[str | None] = mapped_column(String(50), nullable=True)  # alert, intervention, checkin
    reference_id: Mapped[str | None] = mapped_column(String(36), nullable=True)

    user: Mapped["User"] = relationship("User", back_populates="notifications")
