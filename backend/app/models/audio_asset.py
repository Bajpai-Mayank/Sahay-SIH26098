from datetime import datetime
from sqlalchemy import String, Float, Text, Boolean, ForeignKey, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from ..db.base import Base


class AudioAsset(Base):
    __tablename__ = "audio_assets"

    case_id: Mapped[str] = mapped_column(String(36), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False, index=True)
    checkin_id: Mapped[str | None] = mapped_column(String(36), ForeignKey("checkins.id", ondelete="SET NULL"), nullable=True, index=True)
    storage_path: Mapped[str] = mapped_column(String(500), nullable=False)
    duration_seconds: Mapped[float | None] = mapped_column(Float, nullable=True)
    format: Mapped[str] = mapped_column(String(20), default="webm", nullable=False)
    transcript: Mapped[str | None] = mapped_column(Text, nullable=True)
    analysis_status: Mapped[str] = mapped_column(String(20), default="pending", nullable=False)  # pending, processing, completed, failed
    consent_verified: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    retention_until: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)

    checkin: Mapped["Checkin"] = relationship("Checkin", back_populates="audio_assets")
