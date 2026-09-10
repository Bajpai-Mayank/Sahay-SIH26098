from datetime import datetime, timezone
from sqlalchemy import String, Integer, Text, ForeignKey, DateTime, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship
from ..db.base import Base


class Checkin(Base):
    __tablename__ = "checkins"

    case_id: Mapped[str] = mapped_column(String(36), ForeignKey("cases.id", ondelete="CASCADE"), nullable=False, index=True)
    checkin_type: Mapped[str] = mapped_column(String(20), default="scheduled", nullable=False)  # scheduled, on_demand, follow_up
    responses: Mapped[dict] = mapped_column(JSON, default=dict, nullable=False)
    mood_rating: Mapped[int | None] = mapped_column(Integer, nullable=True)  # 1 to 5
    distress_level: Mapped[int | None] = mapped_column(Integer, nullable=True)  # 1 to 10
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    idempotency_key: Mapped[str] = mapped_column(String(64), unique=True, nullable=False, index=True)
    submitted_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc), nullable=False)

    case: Mapped["Case"] = relationship("Case", back_populates="checkins")
    audio_assets: Mapped[list["AudioAsset"]] = relationship("AudioAsset", back_populates="checkin")
    assessments: Mapped[list["Assessment"]] = relationship("Assessment", back_populates="checkin")
