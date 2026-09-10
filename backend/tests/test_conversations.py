import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_conversation_and_ai_reply_flow(client: AsyncClient):
    # 1. Login
    login_res = await client.post(
        "/api/v1/auth/login",
        json={"email": "victim@sahay.org", "password": "Demo1234!"},
    )
    token = login_res.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Get Case
    cases_res = await client.get("/api/v1/cases", headers=headers)
    case_id = cases_res.json()[0]["id"]

    # 3. Create or get conversation
    conv_res = await client.post(
        "/api/v1/conversations",
        json={"case_id": case_id, "conversation_type": "support_chat"},
        headers=headers,
    )
    assert conv_res.status_code == 200
    conv_id = conv_res.json()["id"]

    # 4. Send user message
    msg_payload = {"content": "I felt anxious today, could you give me some grounding tips?"}
    msg_res = await client.post(
        f"/api/v1/conversations/{conv_id}/messages",
        json=msg_payload,
        headers=headers,
    )
    assert msg_res.status_code == 200
    reply = msg_res.json()
    assert reply["sender_type"] == "ai"
    assert len(reply["content"]) > 10

    # 5. Verify history
    history_res = await client.get(f"/api/v1/conversations/{conv_id}/messages", headers=headers)
    assert history_res.status_code == 200
    messages = history_res.json()
    assert len(messages) >= 2
