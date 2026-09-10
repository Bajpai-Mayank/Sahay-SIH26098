from typing import Any, Dict, List, Optional
from pydantic import BaseModel


class PriorityCount(BaseModel):
    label: str
    count: int
    percent: float


class DistrictServiceStatus(BaseModel):
    name: str
    category: str
    available_units: int
    total_units: int
    utilization: str
    contact: str


class CounsellorDashboardResponse(BaseModel):
    assigned_cases_count: int
    pending_reviews_count: int
    urgent_alerts_count: int
    recent_checkins: List[Dict[str, Any]] = []
    upcoming_interventions: List[Dict[str, Any]] = []


class DistrictDashboardResponse(BaseModel):
    district_name: str
    total_active_cases: int
    critical_alerts: int
    active_caseworkers: int
    shelter_utilization: str
    priority_distribution: List[PriorityCount] = []
    district_services: List[DistrictServiceStatus] = []


class StateDashboardResponse(BaseModel):
    state_name: str
    total_cases: int
    active_cases: int
    total_districts: int
    average_response_time_hours: float
    districts: List[Dict[str, Any]] = []
