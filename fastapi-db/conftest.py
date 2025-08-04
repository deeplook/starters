import os
import pytest
from fastapi.testclient import TestClient
from sqlmodel import Session, SQLModel, create_engine
from sqlalchemy.pool import StaticPool

# Check for the existence of the environment file before running tests.
# This ensures that pytest fails immediately if the file is missing.
env_path = os.getenv("MYAPP_ENV_PATH")
if env_path and not os.path.exists(env_path):
    raise FileNotFoundError(
        f"The specified environment file does not exist: {env_path}"
    )


@pytest.fixture(name="engine")
def engine_fixture():
    """Create a new engine for each test function."""
    from src.config import settings

    engine = create_engine(
        settings.database_url,
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
    from main import app
    from src.database import get_session

    def get_session_override():
        return session

    app.dependency_overrides[get_session] = get_session_override
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()
