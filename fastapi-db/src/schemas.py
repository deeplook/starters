from typing import Optional

from sqlmodel import SQLModel


class ItemBase(SQLModel):
    name: str
    description: Optional[str] = None


class ItemCreate(ItemBase):
    pass


class ItemUpdate(SQLModel):
    name: Optional[str] = None
    description: Optional[str] = None
