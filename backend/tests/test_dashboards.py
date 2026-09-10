import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_dashboards_flow(client: AsyncClient):
    # 1. Login as District Admin
    login_res = await client.post(
        "/api/v1/auth/login",
        json={"email": "admin@sahay.org", "password": "Demo1234!"},
    )
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. District Dashboard
    district_res = await client.get("/api/v1/dashboard/district", headers=headers)
    assert district_res.status_code == 200
    d_data = district_res.json()
    assert "total_active_cases" in d_data
    assert "critical_alerts" in d_data
    assert "priority_distribution" in d_data
    assert len(d_data["priority_distribution"]) > 0

    # 3. Counsellor Dashboard
    c_login = await client.post(
        "/api/v1/auth/login",
        json={"email": "counsellor@sahay.org", "password": "Demo1234!"},
    )
    c_token = c_login.json()["access_token"]
    c_headers = {"Authorization": f"Bearer {c_token}"}

    c_res = await client.get("/api/v1/dashboard/counsellor", headers=c_headers)
    assert c_res.status_code == 200
    c_data = c_res.json()
    assert "assigned_cases_count" in c_data
    assert "recent_checkins" in c_data
