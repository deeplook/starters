"""
This is a test file working with the real FastAPI server.
"""

import socket
import subprocess
import time

import httpx
import pytest


def get_free_port():
    """Finds a free port on the host machine."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.bind(("", 0))
        return s.getsockname()[1]


@pytest.fixture(scope="session")
def live_server_url():
    """Fixture to run the FastAPI server on a free port and provide its URL."""
    port = get_free_port()
    base_url = f"http://127.0.0.1:{port}"
    command = [
        "uv",
        "run",
        "--",
        "uvicorn",
        "main:app",
        "--host",
        "127.0.0.1",
        f"--port={port}",
    ]
    process = subprocess.Popen(command)
    # Wait for the server to start up
    time.sleep(2)

    yield base_url

    process.terminate()
    process.wait()


@pytest.fixture
def client(live_server_url):
    """Provides an httpx client for making requests to the live server."""
    return httpx.AsyncClient(base_url=live_server_url)


@pytest.fixture
def reset_state(live_server_url):
    """Resets the API state before each test."""
    with httpx.Client(base_url=live_server_url) as client:
        # Get all items and delete them
        response = client.get("/items")
        if response.status_code == 200:
            for item in response.json():
                client.delete(f"/items/{item['id']}")

        # Add the initial items
        client.post(
            "/items",
            json={"id": 1, "name": "Item 1", "description": "This is the first item."},
        )
        client.post(
            "/items",
            json={"id": 2, "name": "Item 2", "description": "This is the second item."},
        )


@pytest.mark.asyncio
async def test_read_items(client: httpx.AsyncClient, reset_state):
    response = await client.get("/items")
    assert response.status_code == 200
    # The order might not be guaranteed, so we sort by id
    response_json = sorted(response.json(), key=lambda x: x["id"])
    assert len(response_json) == 2
    assert response_json[0]["name"] == "Item 1"
    assert response_json[1]["name"] == "Item 2"


@pytest.mark.asyncio
async def test_read_item(client: httpx.AsyncClient, reset_state):
    # First, create an item to ensure it exists
    response = await client.post(
        "/items", json={"id": 1, "name": "Test Item", "description": "A test item"}
    )
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
    response = await client.post(
        "/items",
        json={"id": 3, "name": "Item 3", "description": "This is the third item."},
    )
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Item 3"
    assert data["description"] == "This is the third item."


@pytest.mark.asyncio
async def test_update_item(client: httpx.AsyncClient, reset_state):
    response = await client.post(
        "/items", json={"id": 1, "name": "Test Item", "description": "A test item"}
    )
    item_id = response.json()["id"]

    response = await client.put(
        f"/items/{item_id}",
        json={
            "id": item_id,
            "name": "Updated Item",
            "description": "This is an updated item.",
        },
    )
    assert response.status_code == 200
    assert response.json()["name"] == "Updated Item"


@pytest.mark.asyncio
async def test_update_item_not_found(client: httpx.AsyncClient, reset_state):
    response = await client.put(
        "/items/999", json={"id": 999, "name": "Non-existent item"}
    )
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_patch_item(client: httpx.AsyncClient, reset_state):
    response = await client.post(
        "/items", json={"id": 1, "name": "Test Item", "description": "A test item"}
    )
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
    response = await client.post(
        "/items", json={"id": 1, "name": "Test Item", "description": "A test item"}
    )
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
    response = await client.post(
        "/items", json={"id": 1, "name": "Test Item", "description": "A test item"}
    )
    item_id = response.json()["id"]

    response = await client.options(f"/items/{item_id}")
    assert response.status_code == 200
    methods = response.json()["methods"]
    assert "GET" in methods
    assert "PUT" in methods
    assert "PATCH" in methods
    assert "DELETE" in methods
