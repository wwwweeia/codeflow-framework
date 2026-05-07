import enum
from datetime import datetime
from sqlalchemy import String, Text, Integer, DateTime, ForeignKey, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.core.database import Base


class AgentStatus(str, enum.Enum):
    DRAFT = "draft"
    ACTIVE = "active"
    INACTIVE = "inactive"


class Model(Base):
    """LLM 模型配置"""
    __tablename__ = "models"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False, comment="模型名称")
    provider: Mapped[str] = mapped_column(String(50), nullable=False, comment="供应商")
    model_type: Mapped[str] = mapped_column(String(50), nullable=False, comment="模型类型")
    version: Mapped[str | None] = mapped_column(String(50), comment="版本号")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now)

    agents: Mapped[list["Agent"]] = relationship(back_populates="model")


class Prompt(Base):
    """提示词模板"""
    __tablename__ = "prompts"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    title: Mapped[str] = mapped_column(String(200), nullable=False, comment="标题")
    content: Mapped[str] = mapped_column(Text, nullable=False, comment="模板内容")
    variables: Mapped[str | None] = mapped_column(String(500), comment="变量列表(JSON)")
    tags: Mapped[str | None] = mapped_column(String(500), comment="标签(JSON数组)")
    created_by: Mapped[str | None] = mapped_column(String(100))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now, onupdate=datetime.now)


class Agent(Base):
    """AI 智能体"""
    __tablename__ = "agents"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False, comment="Agent 名称")
    description: Mapped[str | None] = mapped_column(Text, comment="描述")
    model_id: Mapped[int | None] = mapped_column(ForeignKey("models.id"), comment="关联模型")
    prompt_id: Mapped[int | None] = mapped_column(ForeignKey("prompts.id"), comment="关联提示词")
    status: Mapped[AgentStatus] = mapped_column(
        Enum(AgentStatus), default=AgentStatus.DRAFT, comment="状态"
    )
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now)

    model: Mapped["Model | None"] = relationship(back_populates="agents")
    prompt: Mapped["Prompt | None"] = relationship()
    skills: Mapped[list["Skill"]] = relationship(back_populates="agent")


class Skill(Base):
    """工具技能"""
    __tablename__ = "skills"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False, comment="技能名称")
    description: Mapped[str | None] = mapped_column(Text, comment="描述")
    endpoint_url: Mapped[str | None] = mapped_column(String(500), comment="接口地址")
    agent_id: Mapped[int | None] = mapped_column(ForeignKey("agents.id"), comment="所属 Agent")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now)

    agent: Mapped["Agent | None"] = relationship(back_populates="skills")
