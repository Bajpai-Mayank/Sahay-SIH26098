import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_alerts_and_interventions_flow(client: AsyncClient):
    # 1. Login as Counsellor
    login_res = await client.post(
        "/api/v1/auth/login",
        json={"email": "counsellor@sahay.org", "password": "Demo1234!"},
    )
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Get victim's case
    cases_res = await client.get("/api/v1/cases", headers=headers)
    case_id = cases_res.json()[0]["id"]

    # 3. Create an intervention
    iv_payload = {
        "case_id": case_id,
        "intervention_type": "counselling_session",
        "priority": "HIGH",
        "description": "Weekly supportive counselling video session.",
    }
    iv_res = await client.post(f"/api/v1/cases/{case_id}/interventions", json=iv_payload, headers=headers)
    assert iv_res.status_code == 200
    iv_data = iv_res.json()
    assert iv_data["status"] == "planned"
    iv_id = iv_data["id"]

    # 4. Update intervention
    up_res = await client.put(
        f"/api/v1/interventions/{iv_id}",
        json={"status": "completed", "outcome": "Victim reported feeling calmer and supported."},
        headers=headers,
    )
    assert up_res.status_code == 200
    assert up_res.json()["status"] == "completed"

    # 5. List alerts
    alerts_res = await client.get("/api/v1/alerts", headers=headers)
    assert alerts_res.status_code == 200
    assert isinstance(alerts_res.json(), list)
