import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_checkin_and_support_priority_flow(client: AsyncClient):
    # 1. Login as victim to get token
    login_res = await client.post(
        "/api/v1/auth/login",
        json={"email": "victim@sahay.org", "password": "Demo1234!"},
    )
    assert login_res.status_code == 200
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Get victim's case
    cases_res = await client.get("/api/v1/cases", headers=headers)
    assert cases_res.status_code == 200
    cases = cases_res.json()
    assert len(cases) > 0
    case_id = cases[0]["id"]

    # 3. Submit normal checkin -> LOW priority
    normal_payload = {
        "checkin_type": "scheduled",
        "responses": {"sleep": "good", "meals": "regular"},
        "mood_rating": 4,
        "distress_level": 2,
        "notes": "Everything went smoothly today.",
        "idempotency_key": "test-checkin-normal-001",
    }
    ch_res = await client.post(f"/api/v1/cases/{case_id}/checkins", json=normal_payload, headers=headers)
    assert ch_res.status_code == 200
    ch_data = ch_res.json()
    assert ch_data["mood_rating"] == 4

    # 4. Check Support Priority
    prio_res = await client.get(f"/api/v1/cases/{case_id}/support-priority", headers=headers)
    assert prio_res.status_code == 200
    prio_data = prio_res.json()
    assert prio_data["current_level"] == "LOW"
    assert prio_data["current_score"] <= 35

    # 5. Idempotent checkin submission does not duplicate
    dup_ch_res = await client.post(f"/api/v1/cases/{case_id}/checkins", json=normal_payload, headers=headers)
    assert dup_ch_res.status_code == 200
    assert dup_ch_res.json()["id"] == ch_data["id"]

    # 6. Submit acute distress checkin with safety cues -> URGENT priority & Alert
    crisis_payload = {
        "checkin_type": "on_demand",
        "responses": {"immediate_safety": "unsafe"},
        "mood_rating": 1,
        "distress_level": 9,
        "notes": "I feel like hurting myself and cannot cope anymore.",
        "idempotency_key": "test-checkin-crisis-001",
    }
    crisis_res = await client.post(f"/api/v1/cases/{case_id}/checkins", json=crisis_payload, headers=headers)
    assert crisis_res.status_code == 200

    # 7. Priority should escalate to URGENT
    prio_res2 = await client.get(f"/api/v1/cases/{case_id}/support-priority", headers=headers)
    assert prio_res2.status_code == 200
    prio_data2 = prio_res2.json()
    assert prio_data2["current_level"] == "URGENT"
    assert prio_data2["current_score"] >= 80
    assert prio_data2["requires_human_review"] is True
