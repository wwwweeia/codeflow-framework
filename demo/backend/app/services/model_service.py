from sqlalchemy.orm import Session
from app.models.entity import Model
from app.schemas.schema import ModelCreate


class ModelService:
    def __init__(self, db: Session):
        self.db = db

    def list_models(self, skip: int = 0, limit: int = 100) -> list[Model]:
        return self.db.query(Model).offset(skip).limit(limit).all()

    def get_model(self, model_id: int) -> Model | None:
        return self.db.query(Model).filter(Model.id == model_id).first()

    def create_model(self, data: ModelCreate) -> Model:
        model = Model(**data.model_dump())
        self.db.add(model)
        self.db.commit()
        self.db.refresh(model)
        return model

    def delete_model(self, model_id: int) -> bool:
        model = self.get_model(model_id)
        if not model:
            return False
        self.db.delete(model)
        self.db.commit()
        return True
