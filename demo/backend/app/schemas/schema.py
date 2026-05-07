from datetime import datetime
from typing import Any, Generic, TypeVar
from pydantic import BaseModel, ConfigDict

T = TypeVar("T")


# ─── 通用响应 ──────────────────────────────────────────────────

class Response(BaseModel, Generic[T]):
    code: int = 0
    data: T | None = None
    message: str = "success"


# ─── Model ──────────────────────────────────────────────────────

class ModelCreate(BaseModel):
    name: str
    provider: str
    model_type: str
    version: str | None = None


class ModelRead(BaseModel):
    id: int
    name: str
    provider: str
    model_type: str
    version: str | None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


# ─── Prompt ──────────────────────────────────────────────────────

class PromptCreate(BaseModel):
    title: str
    content: str
    variables: str | None = None
    tags: str | None = None
    created_by: str | None = None


class PromptRead(BaseModel):
    id: int
    title: str
    content: str
    variables: str | None
    tags: str | None
    created_by: str | None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


# ─── Agent ──────────────────────────────────────────────────────

class AgentCreate(BaseModel):
    name: str
    description: str | None = None
    model_id: int | None = None
    prompt_id: int | None = None
    status: str = "draft"


class AgentRead(BaseModel):
    id: int
    name: str
    description: str | None
    model_id: int | None
    prompt_id: int | None
    status: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


# ─── Skill ──────────────────────────────────────────────────────

class SkillCreate(BaseModel):
    name: str
    description: str | None = None
    endpoint_url: str | None = None
    agent_id: int | None = None


class SkillRead(BaseModel):
    id: int
    name: str
    description: str | None
    endpoint_url: str | None
    agent_id: int | None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
