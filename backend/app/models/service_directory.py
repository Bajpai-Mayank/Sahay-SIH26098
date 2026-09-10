from sqlalchemy import String, Text, Boolean, JSON
from sqlalchemy.orm import Mapped, mapped_column
from ..db.base import Base


class ServiceDirectory(Base):
    __tablename__ = "service_directory"

    name: Mapped[str] = mapped_column(String(255), nullable=False)
    service_type: Mapped[str] = mapped_column(String(50), nullable=False, index=True)  # helpline, shelter, legal_aid, counselling, medical
    phone: Mapped[str | None] = mapped_column(String(20), nullable=True)
    address: Mapped[str | None] = mapped_column(Text, nullable=True)
    district: Mapped[str | None] = mapped_column(String(100), nullable=True, index=True)
    state: Mapped[str | None] = mapped_column(String(100), nullable=True, index=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    operating_hours: Mapped[str | None] = mapped_column(String(100), nullable=True)
    metadata_json: Mapped[dict | None] = mapped_column(JSON, nullable=True)

    @property
    def category(self) -> str:
        return self.service_type

    @property
    def phone_number(self) -> str | None:
        return self.phone

    @property
    def available_capacity(self) -> int:
        if self.metadata_json and "available_capacity" in self.metadata_json:
            return self.metadata_json["available_capacity"]
        return 10

    @property
    def total_capacity(self) -> int:
        if self.metadata_json and "total_capacity" in self.metadata_json:
            return self.metadata_json["total_capacity"]
        return 20
