from fastapi import APIRouter
from .endpoints import models_router

router = APIRouter()
router.include_router(models_router, prefix="/models", tags=["models"])
