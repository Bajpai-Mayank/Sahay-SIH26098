import asyncio
import os
import pytest
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession

TEST_DB_URL = "sqlite+aiosqlite:///./sahay_test.db"
os.environ["DATABASE_URL"] = TEST_DB_URL
os.environ["AI_PROVIDER"] = "mock"
os.environ["AI_FALLBACK_TO_MOCK"] = "true"

from app.db.base import Base
import app.models
from app.db.session import get_db
from app.main import app

test_engine = create_async_engine(TEST_DB_URL, echo=False)
TestingSessionLocal = async_sessionmaker(test_engine, expire_on_commit=False, class_=AsyncSession)


@pytest.fixture(scope="session", autouse=True)
def setup_test_database():
    async def init():
        async with test_engine.begin() as conn:
            await conn.run_sync(Base.metadata.drop_all)
            await conn.run_sync(Base.metadata.create_all)
        from app.seed.seed_data import seed_database
        await seed_database()

    asyncio.run(init())
    yield

    async def cleanup():
        async with test_engine.begin() as conn:
            await conn.run_sync(Base.metadata.drop_all)
        await test_engine.dispose()

    asyncio.run(cleanup())
    if os.path.exists("sahay_test.db"):
        try:
            os.remove("sahay_test.db")
        except Exception:
            pass


@pytest.fixture
def anyio_backend():
    return "asyncio"


@pytest.fixture
async def client():
    async def override_get_db():
        async with TestingSessionLocal() as session:
            yield session

    app.dependency_overrides[get_db] = override_get_db
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://testserver") as ac:
        yield ac
    app.dependency_overrides.clear()
