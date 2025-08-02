"""
This is a minimal FastAPI server that implements all HTTP methods,
using a SQLite database for storage.
"""

from contextlib import asynccontextmanager
from typing import List, Optional

from fastapi import Depends, FastAPI, HTTPException
from sqlmodel import Field, Session, SQLModel, create_engine, select

from config import settings


class ItemBase(SQLModel):
    name: str
    description: Optional[str] = None


class Item(ItemBase, table=True):  # type: ignore
    id: Optional[int] = Field(default=None, primary_key=True)


class ItemCreate(ItemBase):
    pass


class ItemUpdate(SQLModel):
    name: Optional[str] = None
    description: Optional[str] = None


connect_args = {"check_same_thread": False}
engine = create_engine(settings.database_url, echo=True, connect_args=connect_args)


def create_db_and_tables():
    SQLModel.metadata.create_all(engine)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    create_db_and_tables()
    yield
    # Shutdown


app = FastAPI(lifespan=lifespan)


def get_session():
    with Session(engine) as session:
        yield session


@app.get("/items", response_model=List[Item])
def read_items(session: Session = Depends(get_session)):
    """Retrieve all items."""
    items = session.exec(select(Item)).all()
    return items


@app.get("/items/{item_id}", response_model=Item)
def read_item(item_id: int, session: Session = Depends(get_session)):
    """Retrieve a single item by its ID."""
    item = session.get(Item, item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


@app.post("/items", response_model=Item, status_code=201)
def create_item(item: ItemCreate, session: Session = Depends(get_session)):
    """Create a new item."""
    db_item = Item.model_validate(item)
    session.add(db_item)
    session.commit()
    session.refresh(db_item)
    return db_item


@app.put("/items/{item_id}", response_model=Item)
def update_item(
    item_id: int, item: ItemCreate, session: Session = Depends(get_session)
):
    """Update an existing item."""
    db_item = session.get(Item, item_id)
    if not db_item:
        raise HTTPException(status_code=404, detail="Item not found")
    item_data = item.model_dump(exclude_unset=True)
    for key, value in item_data.items():
        setattr(db_item, key, value)
    session.add(db_item)
    session.commit()
    session.refresh(db_item)
    return db_item


@app.patch("/items/{item_id}", response_model=Item)
def patch_item(item_id: int, item: ItemUpdate, session: Session = Depends(get_session)):
    """Partially update an existing item."""
    db_item = session.get(Item, item_id)
    if not db_item:
        raise HTTPException(status_code=404, detail="Item not found")
    item_data = item.model_dump(exclude_unset=True)
    for key, value in item_data.items():
        setattr(db_item, key, value)
    session.add(db_item)
    session.commit()
    session.refresh(db_item)
    return db_item


@app.delete("/items/{item_id}", status_code=204)
def delete_item(item_id: int, session: Session = Depends(get_session)):
    """Delete an item."""
    item = session.get(Item, item_id)
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    session.delete(item)
    session.commit()
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

    uvicorn.run(app, host="0.0.0.0", port=settings.port)
