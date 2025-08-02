import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, SQLModel, create_engine
from sqlalchemy.pool import StaticPool

from config import MYAPP_DATABASE_URL
from main import app, get_session


if not MYAPP_DATABASE_URL:
    raise ValueError("MYAPP_DATABASE_URL is not set")


@pytest.fixture(name="engine")
def engine_fixture():
    """Create a new engine for each test function."""
    engine = create_engine(
        MYAPP_DATABASE_URL,
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    yield engine
    SQLModel.metadata.drop_all(engine)


@pytest.fixture(name="session")
def session_fixture(engine):
    """Create a new session for each test function."""
    with Session(engine) as session:
        yield session


@pytest.fixture(name="client")
def client_fixture(session: Session):
    """Create a new client for each test function."""

    def get_session_override():
        return session

    app.dependency_overrides[get_session] = get_session_override
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()
