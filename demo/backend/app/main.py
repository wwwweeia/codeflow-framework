from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import PROJECT_NAME, VERSION, API_PREFIX
from app.core.database import engine
from app.models.entity import Base
from app.api.v1.router import router as v1_router

# 建表
Base.metadata.create_all(bind=engine)

app = FastAPI(title=PROJECT_NAME, version=VERSION)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(v1_router, prefix=API_PREFIX)


@app.get("/health")
def health_check():
    return {"status": "ok", "service": PROJECT_NAME, "version": VERSION}
