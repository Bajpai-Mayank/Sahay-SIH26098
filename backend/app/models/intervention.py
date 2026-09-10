from datetime import datetime
from sqlalchemy import String, Text, ForeignKey, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from ..db.base import Base


class Intervention(Base):
    __tablename__ = "interventions"

    case_id: Mapped[str] = mapped_column(String(36), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False, index=True)
    alert_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("alerts.id", ondelete="SET NULL"), nullable=True, index=True)
    created_by: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), nullable=False)
    intervention_type: Mapped[str] = mapped_column(String(50), nullable=False)  # contact, follow_up, referral, counselling_session, safety_plan
    status: Mapped[str] = mapped_column(String(20), default="planned", nullable=False, index=True)  # planned, in_progress, completed, cancelled
    priority: Mapped[str] = mapped_column(String(20), default="MODERATE", nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    scheduled_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    outcome: Mapped[str | None] = mapped_column(Text, nullable=True)

    case: Mapped["Case"] = relationship("Case", back_populates="interventions")
    alert: Mapped["Alert"] = relationship("Alert", back_populates="interventions")
