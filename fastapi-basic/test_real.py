"""
This is a test file working with the real FastAPI server.
"""

import subprocess
import time

import httpx
import pytest
from dotenv import dotenv_values

from main import Item


env = dotenv_values("./.env")
PORT = int(env.get("PORT", "8000"))
# Define the base URL for the running server
BASE_URL = f"http://127.0.0.1:{PORT}"


@pytest.fixture(scope="session", autouse=True)
def live_server():
    """Fixture to run the FastAPI server in a separate process for the whole session."""
    # Command to run uvicorn using uv run
    command = ["uv", "run", "--", "uvicorn", "main:app", "--host", "127.0.0.1", "--port", "8001"]
    
    # Start the server process
    process = subprocess.Popen(command)
    
    # Wait for the server to start up
    time.sleep(2)
    
    # Yield control to the tests
    yield
    
    # Terminate the server process after tests are done
    process.terminate()
    process.wait()

@pytest.fixture
def client():
    """Provides an httpx client for making requests to the live server."""
    return httpx.AsyncClient(base_url=BASE_URL)

@pytest.fixture
def reset_state():
    """Resets the API state before each test."""
    with httpx.Client(base_url=BASE_URL) as client:
        # Get all items and delete them
        response = client.get("/items")
        if response.status_code == 200:
            for item in response.json():
                client.delete(f"/items/{item['id']}")
                
        # Add the initial items
        client.post("/items", json={"id": 1, "name": "Item 1", "description": "This is the first item."})
        client.post("/items", json={"id": 2, "name": "Item 2", "description": "This is the second item."})


@pytest.mark.asyncio
async def test_read_items(client: httpx.AsyncClient, reset_state):
    
    response = await client.get("/items")
    assert response.status_code == 200
    # The order might not be guaranteed, so we sort by id
    response_json = sorted(response.json(), key=lambda x: x['id'])
    assert len(response_json) == 2
    assert response_json[0]["name"] == "Item 1"
    assert response_json[1]["name"] == "Item 2"

@pytest.mark.asyncio
async def test_read_item(client: httpx.AsyncClient, reset_state):
    
    # First, create an item to ensure it exists
    response = await client.post("/items", json={"id": 1, "name": "Test Item", "description": "A test item"})
    item_id = response.json()["id"]
    
    response = await client.get(f"/items/{item_id}")
    assert response.status_code == 200
    assert response.json()["name"] == "Test Item"

@pytest.mark.asyncio
async def test_read_item_not_found(client: httpx.AsyncClient, reset_state):
    
    response = await client.get("/items/999")
    assert response.status_code == 404

@pytest.mark.asyncio
async def test_create_item(client: httpx.AsyncClient, reset_state):
    
    response = await client.post("/items", json={"id": 3, "name": "Item 3", "description": "This is the third item."})
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Item 3"
    assert data["description"] == "This is the third item."

@pytest.mark.asyncio
async def test_update_item(client: httpx.AsyncClient, reset_state):
    
    response = await client.post("/items", json={"id": 1, "name": "Test Item", "description": "A test item"})
    item_id = response.json()["id"]

    response = await client.put(f"/items/{item_id}", json={"id": item_id, "name": "Updated Item", "description": "This is an updated item."})
    assert response.status_code == 200
    assert response.json()["name"] == "Updated Item"

@pytest.mark.asyncio
async def test_update_item_not_found(client: httpx.AsyncClient, reset_state):
    
    response = await client.put("/items/999", json={"id": 999, "name": "Non-existent item"})
    assert response.status_code == 404

@pytest.mark.asyncio
async def test_patch_item(client: httpx.AsyncClient, reset_state):
    
    response = await client.post("/items", json={"id": 1, "name": "Test Item", "description": "A test item"})
    item_id = response.json()["id"]

    response = await client.patch(f"/items/{item_id}", json={"name": "Patched Item"})
    assert response.status_code == 200
    assert response.json()["name"] == "Patched Item"

@pytest.mark.asyncio
async def test_patch_item_not_found(client: httpx.AsyncClient, reset_state):
    
    response = await client.patch("/items/999", json={"name": "Non-existent item"})
    assert response.status_code == 404

@pytest.mark.asyncio
async def test_delete_item(client: httpx.AsyncClient, reset_state):
    
    response = await client.post("/items", json={"id": 1, "name": "Test Item", "description": "A test item"})
    item_id = response.json()["id"]

    response = await client.delete(f"/items/{item_id}")
    assert response.status_code == 204

@pytest.mark.asyncio
async def test_delete_item_not_found(client: httpx.AsyncClient, reset_state):
    
    response = await client.delete("/items/999")
    assert response.status_code == 404

@pytest.mark.asyncio
async def test_options_items(client: httpx.AsyncClient, reset_state):
    
    response = await client.options("/items")
    assert response.status_code == 200
    assert "GET" in response.json()["methods"]
    assert "POST" in response.json()["methods"]

@pytest.mark.asyncio
async def test_options_item_id(client: httpx.AsyncClient, reset_state):
    
    response = await client.post("/items", json={"id": 1, "name": "Test Item", "description": "A test item"})
    item_id = response.json()["id"]
    
    response = await client.options(f"/items/{item_id}")
    assert response.status_code == 200
    methods = response.json()["methods"]
    assert "GET" in methods
    assert "PUT" in methods
    assert "PATCH" in methods
    assert "DELETE" in methods
