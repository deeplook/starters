from sqlmodel import Field, SQLModel


class Item(SQLModel, table=True):  # type: ignore
    id: int | None = Field(default=None, primary_key=True)
    name: str
    description: str | None = None
