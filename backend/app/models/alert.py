from datetime import datetime
from sqlalchemy import String, Text, ForeignKey, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from ..db.base import Base


class Alert(Base):
    __tablename__ = "alerts"

    case_id: Mapped[str] = mapped_column(String(36), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False, index=True)
    assessment_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("assessments.id", ondelete="SET NULL"), nullable=True, index=True)
    alert_type: Mapped[str] = mapped_column(String(30), nullable=False)  # priority_change, safety_cue, missed_checkin, trend_alert
    severity: Mapped[str] = mapped_column(String(20), nullable=False, index=True)  # INFO, WARNING, CRITICAL
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    status: Mapped[str] = mapped_column(String(20), default="pending", nullable=False, index=True)  # pending, acknowledged, assigned, resolved, dismissed
    acknowledged_by: Mapped[str | None] = mapped_column(String(36), ForeignKey("users.id"), nullable=True)
    acknowledged_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    assigned_to: Mapped[str | None] = mapped_column(String(36), ForeignKey("users.id"), nullable=True)

    case: Mapped["Case"] = relationship("Case", back_populates="alerts")
    assessment: Mapped["Assessment"] = relationship("Assessment", back_populates="alerts")
    interventions: Mapped[list["Intervention"]] = relationship("Intervention", back_populates="alert")
