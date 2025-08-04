from sqlmodel import Session, select

from . import models, schemas


def get_item(session: Session, item_id: int):
    return session.get(models.Item, item_id)


def get_items(session: Session):
    return session.exec(select(models.Item)).all()


def create_item(session: Session, item: schemas.ItemCreate):
    db_item = models.Item.model_validate(item)
    session.add(db_item)
    session.commit()
    session.refresh(db_item)
    return db_item


def update_item(
    session: Session, item_id: int, item: schemas.ItemUpdate | schemas.ItemCreate
):
    """Update an item."""
    db_item = session.get(models.Item, item_id)
    if not db_item:
        return None
    item_data = item.model_dump(exclude_unset=True)
    for key, value in item_data.items():
        setattr(db_item, key, value)
    session.add(db_item)
    session.commit()
    session.refresh(db_item)
    return db_item


def upsert_item(session: Session, item: schemas.ItemCreate):
    """
    Update an item if it exists, otherwise create it.
    This function is not used in the API, but is useful for testing.
    """
    db_item = session.get(models.Item, item.id)
    if db_item:
        item_data = item.model_dump(exclude_unset=True)
        for key, value in item_data.items():
            setattr(db_item, key, value)
    else:
        db_item = models.Item.model_validate(item)
    session.add(db_item)
    session.commit()
    session.refresh(db_item)
    return db_item


def delete_item(session: Session, item_id: int):
    item = session.get(models.Item, item_id)
    if not item:
        return None
    session.delete(item)
    session.commit()
    return True
