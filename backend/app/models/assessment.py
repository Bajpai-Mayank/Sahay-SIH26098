from datetime import datetime
from sqlalchemy import String, Integer, Float, Boolean, ForeignKey, DateTime, JSON, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from ..db.base import Base


class Assessment(Base):
    __tablename__ = "assessments"

    case_id: Mapped[str] = mapped_column(String(36), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False, index=True)
    checkin_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("checkins.id", ondelete="SET NULL"), nullable=True, index=True)
    assessment_type: Mapped[str] = mapped_column(String(30), default="automated", nullable=False)  # automated, manual, hybrid
    priority: Mapped[str] = mapped_column(String(20), nullable=False, index=True)  # LOW, MODERATE, HIGH, URGENT
    score: Mapped[int] = mapped_column(Integer, nullable=False)  # 0 to 100
    confidence: Mapped[float] = mapped_column(Float, default=0.8, nullable=False)  # 0.0 to 1.0
    trend: Mapped[str] = mapped_column(String(20), default="STABLE", nullable=False)  # STABLE, INCREASING, DECREASING, INSUFFICIENT_DATA
    reasons: Mapped[list] = mapped_column(JSON, default=list, nullable=False)  # Array of explainable reason strings
    requires_human_review: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    ai_provider: Mapped[str] = mapped_column(String(50), default="mock", nullable=False)
    ai_model: Mapped[str | None] = mapped_column(String(100), nullable=True)
    reviewed_by: Mapped[str | None] = mapped_column(String(36), ForeignKey("users.id"), nullable=True)
    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    case: Mapped["Case"] = relationship("Case", back_populates="assessments")
    checkin: Mapped["Checkin"] = relationship("Checkin", back_populates="assessments")
    features: Mapped[list["AssessmentFeature"]] = relationship("AssessmentFeature", back_populates="assessment", cascade="all, delete-orphan")
    events: Mapped[list["SupportPriorityEvent"]] = relationship("SupportPriorityEvent", back_populates="assessment", cascade="all, delete-orphan")
    alerts: Mapped[list["Alert"]] = relationship("Alert", back_populates="assessment")


class AssessmentFeature(Base):
    __tablename__ = "assessment_features"

    assessment_id: Mapped[str] = mapped_column(String(36), ForeignKey("assessments.id", ondelete="CASCADE"), nullable=False, index=True)
    feature_name: Mapped[str] = mapped_column(String(100), nullable=False)
    feature_value: Mapped[float] = mapped_column(Float, nullable=False)  # 0.0 to 1.0
    source: Mapped[str] = mapped_column(String(50), nullable=False)  # checkin, text_analysis, voice_analysis, behaviour
    evidence: Mapped[str | None] = mapped_column(Text, nullable=True)

    assessment: Mapped["Assessment"] = relationship("Assessment", back_populates="features")


class SupportPriorityEvent(Base):
    __tablename__ = "support_priority_events"

    case_id: Mapped[str] = mapped_column(String(36), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False, index=True)
    assessment_id: Mapped[str] = mapped_column(String(36), ForeignKey("assessments.id", ondelete="CASCADE"), nullable=False, index=True)
    priority: Mapped[str] = mapped_column(String(20), nullable=False, index=True)
    score: Mapped[int] = mapped_column(Integer, nullable=False)
    trend: Mapped[str] = mapped_column(String(20), nullable=False)
    snapshot: Mapped[dict] = mapped_column(JSON, default=dict, nullable=False)

    assessment: Mapped["Assessment"] = relationship("Assessment", back_populates="events")
