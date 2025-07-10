"""
This is a test file working with the TestClient.
"""

import pytest
from fastapi.testclient import TestClient

from main import Item, app, items, next_id


@pytest.fixture(autouse=True)
def reset_items():
    """Reset the items list and next_id before each test."""
    global items, next_id
    items.clear()
    items.extend(
        [
            Item(id=1, name="Item 1", description="This is the first item."),
            Item(id=2, name="Item 2", description="This is the second item."),
        ]
    )
    next_id = 3


def test_read_items():
    with TestClient(app) as client:
        response = client.get("/items")
    assert response.status_code == 200
    assert response.json() == [
        {"id": 1, "name": "Item 1", "description": "This is the first item."},
        {"id": 2, "name": "Item 2", "description": "This is the second item."},
    ]


def test_read_item():
    with TestClient(app) as client:
        response = client.get("/items/1")
    assert response.status_code == 200
    assert response.json() == {
        "id": 1,
        "name": "Item 1",
        "description": "This is the first item.",
    }


def test_read_item_not_found():
    with TestClient(app) as client:
        response = client.get("/items/99")
    assert response.status_code == 404
    assert response.json() == {"detail": "Item not found"}


def test_create_item():
    with TestClient(app) as client:
        response = client.post(
            "/items",
            json={"id": 3, "name": "Item 3", "description": "This is the third item."},
        )
    assert response.status_code == 201
    assert response.json() == {
        "id": 3,
        "name": "Item 3",
        "description": "This is the third item.",
    }


def test_update_item():
    with TestClient(app) as client:
        response = client.put(
            "/items/1",
            json={
                "id": 1,
                "name": "Updated Item 1",
                "description": "This is the updated first item.",
            },
        )
    assert response.status_code == 200
    assert response.json() == {
        "id": 1,
        "name": "Updated Item 1",
        "description": "This is the updated first item.",
    }


def test_update_item_not_found():
    with TestClient(app) as client:
        response = client.put("/items/99", json={"id": 99, "name": "Non-existent item"})
    assert response.status_code == 404
    assert response.json() == {"detail": "Item not found"}


def test_patch_item():
    with TestClient(app) as client:
        response = client.patch("/items/1", json={"name": "Patched Item 1"})
    assert response.status_code == 200
    assert response.json() == {
        "id": 1,
        "name": "Patched Item 1",
        "description": "This is the first item.",
    }


def test_patch_item_not_found():
    with TestClient(app) as client:
        response = client.patch("/items/99", json={"name": "Non-existent item"})
    assert response.status_code == 404
    assert response.json() == {"detail": "Item not found"}


def test_delete_item():
    with TestClient(app) as client:
        response = client.delete("/items/1")
    assert response.status_code == 204


def test_delete_item_not_found():
    with TestClient(app) as client:
        response = client.delete("/items/99")
    assert response.status_code == 404
    assert response.json() == {"detail": "Item not found"}


def test_options_items():
    with TestClient(app) as client:
        response = client.options("/items")
    assert response.status_code == 200
    assert response.json() == {"methods": ["GET", "POST", "OPTIONS"]}


def test_options_item_id():
    with TestClient(app) as client:
        response = client.options("/items/1")
    assert response.status_code == 200
    assert response.json() == {"methods": ["GET", "PUT", "PATCH", "DELETE", "OPTIONS"]}
