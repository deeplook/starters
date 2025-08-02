"""
This is a test file working with the TestClient.

❯ MYAPP_ENV_PATH=myapp.test.env uv run pytest test_testclient.py
"""

from fastapi.testclient import TestClient


def test_create_item(client: TestClient):
    response = client.post(
        "/items/", json={"name": "Test Item", "description": "This is a test item."}
    )
    assert response.status_code == 201, response.text
    data = response.json()
    assert data["name"] == "Test Item"
    assert data["description"] == "This is a test item."
    assert "id" in data
    item_id = data["id"]

    response = client.get(f"/items/{item_id}")
    assert response.status_code == 200, response.text
    data = response.json()
    assert data["name"] == "Test Item"
    assert data["description"] == "This is a test item."


def test_read_items(client: TestClient):
    response = client.get("/items/")
    assert response.status_code == 200, response.text


def test_read_item(client: TestClient):
    response = client.post(
        "/items/", json={"name": "Test Item 2", "description": "Another test item."}
    )
    assert response.status_code == 201, response.text
    item_id = response.json()["id"]

    response = client.get(f"/items/{item_id}")
    assert response.status_code == 200, response.text
    data = response.json()
    assert data["name"] == "Test Item 2"


def test_read_item_not_found(client: TestClient):
    response = client.get("/items/999")
    assert response.status_code == 404


def test_update_item(client: TestClient):
    response = client.post(
        "/items/", json={"name": "Update Me", "description": "This will be updated."}
    )
    assert response.status_code == 201, response.text
    item_id = response.json()["id"]

    response = client.put(
        f"/items/{item_id}",
        json={"name": "Updated", "description": "This has been updated."},
    )
    assert response.status_code == 200, response.text
    data = response.json()
    assert data["name"] == "Updated"


def test_update_item_not_found(client: TestClient):
    response = client.put(
        "/items/999", json={"name": "Doesn't exist", "description": "Cannot update."}
    )
    assert response.status_code == 404


def test_patch_item(client: TestClient):
    response = client.post(
        "/items/", json={"name": "Patch Me", "description": "This will be patched."}
    )
    assert response.status_code == 201, response.text
    item_id = response.json()["id"]

    response = client.patch(f"/items/{item_id}", json={"name": "Patched"})
    assert response.status_code == 200, response.text
    data = response.json()
    assert data["name"] == "Patched"


def test_patch_item_not_found(client: TestClient):
    response = client.patch("/items/999", json={"name": "Doesn't exist"})
    assert response.status_code == 404


def test_delete_item(client: TestClient):
    response = client.post(
        "/items/", json={"name": "Delete Me", "description": "This will be deleted."}
    )
    assert response.status_code == 201, response.text
    item_id = response.json()["id"]

    response = client.delete(f"/items/{item_id}")
    assert response.status_code == 204, response.text

    response = client.get(f"/items/{item_id}")
    assert response.status_code == 404, response.text


def test_delete_item_not_found(client: TestClient):
    response = client.delete("/items/999")
    assert response.status_code == 404
