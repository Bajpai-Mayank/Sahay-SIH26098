import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_register_and_login_flow(client: AsyncClient):
    # 1. Register new user
    reg_payload = {
        "email": "test_user_01@example.com",
        "password": "Password123!",
        "full_name": "Test User",
        "phone_number": "+919999999999",
        "role": "VICTIM",
    }
    reg_res = await client.post("/api/v1/auth/register", json=reg_payload)
    assert reg_res.status_code == 200
    reg_data = reg_res.json()
    assert "access_token" in reg_data
    assert "refresh_token" in reg_data
    assert reg_data["user"]["email"] == "test_user_01@example.com"
    assert "VICTIM" in reg_data["user"]["roles"]

    # 2. Duplicate registration fails
    dup_res = await client.post("/api/v1/auth/register", json=reg_payload)
    assert dup_res.status_code == 400

    # 3. Login with correct password
    login_payload = {
        "email": "test_user_01@example.com",
        "password": "Password123!",
    }
    login_res = await client.post("/api/v1/auth/login", json=login_payload)
    assert login_res.status_code == 200
    login_data = login_res.json()
    assert "access_token" in login_data
    assert login_data["user"]["email"] == "test_user_01@example.com"

    # 4. Login with incorrect password fails
    bad_login_res = await client.post(
        "/api/v1/auth/login",
        json={"email": "test_user_01@example.com", "password": "WrongPassword!"},
    )
    assert bad_login_res.status_code == 401

    # 5. Refresh token
    refresh_res = await client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": login_data["refresh_token"]},
    )
    assert refresh_res.status_code == 200
    assert "access_token" in refresh_res.json()
