from datetime import datetime, timezone
from sqlalchemy import String, ForeignKey, DateTime, Boolean
from sqlalchemy.orm import Mapped, mapped_column, relationship
from ..db.base import Base


class Case(Base):
    __tablename__ = "cases"

    case_number: Mapped[str] = mapped_column(String(20), unique=True, nullable=False, index=True)
    victim_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), nullable=False, index=True)
    status: Mapped[str] = mapped_column(String(20), default="active", nullable=False, index=True)  # active, monitoring, closed, archived
    district: Mapped[str | None] = mapped_column(String(100), nullable=True, index=True)
    state: Mapped[str | None] = mapped_column(String(100), nullable=True, index=True)
    closed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    victim: Mapped["User"] = relationship("User", back_populates="cases", foreign_keys=[victim_id])
    assignments: Mapped[list["CaseAssignment"]] = relationship("CaseAssignment", back_populates="case", cascade="all, delete-orphan")
    consents: Mapped[list["Consent"]] = relationship("Consent", back_populates="case", cascade="all, delete-orphan")
    checkins: Mapped[list["Checkin"]] = relationship("Checkin", back_populates="case", cascade="all, delete-orphan")
    conversations: Mapped[list["Conversation"]] = relationship("Conversation", back_populates="case", cascade="all, delete-orphan")
    assessments: Mapped[list["Assessment"]] = relationship("Assessment", back_populates="case", cascade="all, delete-orphan")
    alerts: Mapped[list["Alert"]] = relationship("Alert", back_populates="case", cascade="all, delete-orphan")
    interventions: Mapped[list["Intervention"]] = relationship("Intervention", back_populates="case", cascade="all, delete-orphan")


class CaseAssignment(Base):
    __tablename__ = "case_assignments"

    case_id: Mapped[str] = mapped_column(String(36), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False, index=True)
    counsellor_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), nullable=False, index=True)
    assigned_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)
    unassigned_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    is_primary: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)

    case: Mapped["Case"] = relationship("Case", back_populates="assignments")
    counsellor: Mapped["User"] = relationship("User", back_populates="assigned_cases")
