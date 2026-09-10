import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_health_endpoint(client: AsyncClient):
    response = await client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["service"] == "SAHAY-AI"
    assert "timestamp" in data
    assert data["ai_provider"] in ["mock", "gemini", "ollama", "huggingface"]


@pytest.mark.asyncio
async def test_health_db_endpoint(client: AsyncClient):
    response = await client.get("/health/db")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "connected"
    assert "latency_ms" in data


@pytest.mark.asyncio
async def test_health_dependencies_endpoint(client: AsyncClient):
    response = await client.get("/health/dependencies")
    assert response.status_code == 200
    data = response.json()
    assert data["service"] == "SAHAY-AI"
    assert data["database"]["status"] == "connected"
    assert "ai_provider" in data
    assert data["ai_provider"]["status"] in ["ok", "unconfigured"]
