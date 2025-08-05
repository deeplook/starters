"""
This is a minimal FastAPI server that implements all HTTP methods,
using a SQLite database for storage.
"""

import os
from contextlib import asynccontextmanager
from typing import Annotated, List

from fastapi import Depends, FastAPI, HTTPException, status
from sqlmodel import Session

from src import crud, models, schemas
from src.config import settings
from src.database import create_db_and_tables, get_session


# The `AsyncContextManager` is used to manage the lifecycle of the application.
# In this case, it's used to create the database and tables when the application
# starts up.
#
# The `lifespan` function is a context manager that will be executed before the
# application starts receiving requests.
#
# It's a good practice to use a context manager to manage resources that need
# to be cleaned up when the application shuts down.
#
# For more information, see:
# https://fastapi.tiangolo.com/advanced/events/
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    # Create the directory if it doesn't exist
    db_path = settings.database_url.replace("sqlite:///", "")
    db_dir = os.path.dirname(db_path)
    if db_dir:
        os.makedirs(db_dir, exist_ok=True)
    create_db_and_tables()
    yield
    # Shutdown


app = FastAPI(lifespan=lifespan)

DBSession = Annotated[Session, Depends(get_session)]


@app.get("/items", response_model=List[models.Item])
def read_items(session: DBSession):
    """Retrieve all items."""
    return crud.get_items(session=session)


@app.get("/items/{item_id}", response_model=models.Item)
def read_item(item_id: int, session: DBSession):
    """Retrieve a single item by its ID."""
    db_item = crud.get_item(session=session, item_id=item_id)
    if db_item is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Item not found"
        )
    return db_item


@app.post(
    "/items",
    response_model=models.Item,
    status_code=status.HTTP_201_CREATED,
)
def create_item(item: schemas.ItemCreate, session: DBSession):
    """Create a new item."""
    return crud.create_item(session=session, item=item)


@app.put("/items/{item_id}", response_model=models.Item)
def update_item(item_id: int, item: schemas.ItemCreate, session: DBSession):
    """Update an existing item."""
    db_item = crud.update_item(session=session, item_id=item_id, item=item)
    if db_item is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Item not found"
        )
    return db_item


@app.patch("/items/{item_id}", response_model=models.Item)
def patch_item(item_id: int, item: schemas.ItemUpdate, session: DBSession):
    """Partially update an existing item."""
    db_item = crud.update_item(session=session, item_id=item_id, item=item)
    if db_item is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Item not found"
        )
    return db_item


@app.delete("/items/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_item(item_id: int, session: DBSession):
    """Delete an item."""
    if not crud.delete_item(session=session, item_id=item_id):
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Item not found"
        )
    return


if __name__ == "__main__":
    from src.cli import cli

    cli()
