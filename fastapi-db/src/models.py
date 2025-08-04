from typing import Optional

from sqlmodel import Field, SQLModel


class Item(SQLModel, table=True):  # type: ignore
    id: Optional[int] = Field(default=None, primary_key=True)
    name: str
    description: Optional[str] = None
