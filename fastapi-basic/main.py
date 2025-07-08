"""
This is a minimal FastAPI server that implements all HTTP methods.
"""

from typing import List, Optional

from dotenv import dotenv_values
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel


env = dotenv_values("./.env")
PORT = int(env.get("PORT", "8000"))


class Item(BaseModel):
    id: int
    name: str
    description: Optional[str] = None


class UpdateItem(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None


# Pseudo-database
items: List[Item] = [
    Item(id=1, name="Item 1", description="This is the first item."),
    Item(id=2, name="Item 2", description="This is the second item."),
]
next_id = 3


app = FastAPI()


@app.get("/items", response_model=List[Item])
async def read_items() -> List[Item]:
    """Retrieve all items."""
    return items


@app.get("/items/{item_id}", response_model=Item)
async def read_item(item_id: int) -> Item:
    """Retrieve a single item by its ID."""
    item = next((item for item in items if item.id == item_id), None)
    if item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


@app.post("/items", response_model=Item, status_code=201)
async def create_item(item_data: Item) -> Item:
    """Create a new item."""
    global next_id
    new_item = Item(id=next_id, name=item_data.name, description=item_data.description)
    items.append(new_item)
    next_id += 1
    return new_item


@app.put("/items/{item_id}", response_model=Item)
async def update_item(item_id: int, item_data: Item) -> Item:
    """Update an existing item."""
    item_index = next(
        (index for index, item in enumerate(items) if item.id == item_id), None
    )
    if item_index is None:
        raise HTTPException(status_code=404, detail="Item not found")

    updated_item = Item(
        id=item_id, name=item_data.name, description=item_data.description
    )
    items[item_index] = updated_item
    return updated_item


@app.patch("/items/{item_id}", response_model=Item)
async def patch_item(item_id: int, item_data: UpdateItem) -> Item:
    """Partially update an existing item."""
    item = next((item for item in items if item.id == item_id), None)
    if item is None:
        raise HTTPException(status_code=404, detail="Item not found")

    update_data = item_data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(item, key, value)
    return item


@app.delete("/items/{item_id}", status_code=204)
async def delete_item(item_id: int) -> None:
    """Delete an item."""
    global items
    original_length = len(items)
    items = [item for item in items if item.id != item_id]
    if len(items) == original_length:
        raise HTTPException(status_code=404, detail="Item not found")
    return


@app.options("/items")
async def options_items() -> dict[str, list[str]]:
    """Get available methods for the /items endpoint."""
    return {"methods": ["GET", "POST", "OPTIONS"]}


@app.options("/items/{item_id}")
async def options_item_id(item_id: int) -> dict[str, list[str]]:
    """Get available methods for the /items/{item_id} endpoint."""
    return {"methods": ["GET", "PUT", "PATCH", "DELETE", "OPTIONS"]}


# FastAPI automatically handles HEAD requests if a GET route is defined.
# No explicit HEAD endpoint is needed.

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=PORT)
