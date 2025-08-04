"""
This is a minimal FastAPI server that implements all HTTP methods,
using a SQLite database for storage.
"""

from contextlib import asynccontextmanager
from typing import List

from fastapi import Depends, FastAPI, HTTPException
from sqlmodel import Session

from src import crud, models, schemas
from src.database import create_db_and_tables, get_session


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    create_db_and_tables()
    yield
    # Shutdown


app = FastAPI(lifespan=lifespan)


@app.get("/items", response_model=List[models.Item])
def read_items(session: Session = Depends(get_session)):
    """Retrieve all items."""
    return crud.get_items(session=session)


@app.get("/items/{item_id}", response_model=models.Item)
def read_item(item_id: int, session: Session = Depends(get_session)):
    """Retrieve a single item by its ID."""
    db_item = crud.get_item(session=session, item_id=item_id)
    if db_item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    return db_item


@app.post("/items", response_model=models.Item, status_code=201)
def create_item(item: schemas.ItemCreate, session: Session = Depends(get_session)):
    """Create a new item."""
    return crud.create_item(session=session, item=item)


@app.put("/items/{item_id}", response_model=models.Item)
def update_item(
    item_id: int, item: schemas.ItemCreate, session: Session = Depends(get_session)
):
    """Update an existing item."""
    db_item = crud.update_item(session=session, item_id=item_id, item=item)
    if db_item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    return db_item


@app.patch("/items/{item_id}", response_model=models.Item)
def patch_item(
    item_id: int, item: schemas.ItemUpdate, session: Session = Depends(get_session)
):
    """Partially update an existing item."""
    db_item = crud.patch_item(session=session, item_id=item_id, item=item)
    if db_item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    return db_item


@app.delete("/items/{item_id}", status_code=204)
def delete_item(item_id: int, session: Session = Depends(get_session)):
    """Delete an item."""
    if not crud.delete_item(session=session, item_id=item_id):
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
    from src.config import settings

    uvicorn.run(app, host="0.0.0.0", port=settings.port)
