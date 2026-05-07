"""种子数据脚本 — 初始化 AI Prompt Lab 演示数据"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from app.core.database import engine, SessionLocal
from app.models.entity import Base, Model, Prompt, Agent, Skill, AgentStatus

# 重建表
Base.metadata.drop_all(bind=engine)
Base.metadata.create_all(bind=engine)

db = SessionLocal()

# ─── Models ─────────────────────────────────────────────────────
models = [
    Model(name="GPT-4o", provider="OpenAI", model_type="LLM", version="gpt-4o-2024-08-06"),
    Model(name="Claude Sonnet 4", provider="Anthropic", model_type="LLM", version="claude-sonnet-4-20250514"),
    Model(name="GLM-4", provider="Zhipu", model_type="LLM", version="glm-4"),
]
db.add_all(models)
db.flush()

# ─── Prompts ─────────────────────────────────────────────────────
prompts = [
    Prompt(
        title="代码审查助手",
        content="请审查以下代码并给出改进建议：\n\n{code}",
        variables='["code"]',
        tags='["代码", "审查"]',
        created_by="system",
    ),
    Prompt(
        title="Bug 报告模板",
        content="请描述以下 bug 的复现步骤和预期行为：\n\n{bug_description}",
        variables='["bug_description"]',
        tags='["bug", "模板"]',
        created_by="system",
    ),
    Prompt(
        title="技术方案生成",
        content="基于以下需求，生成技术方案：\n\n{requirement}\n\n约束条件：{constraints}",
        variables='["requirement", "constraints"]',
        tags='["方案", "设计"]',
        created_by="system",
    ),
]
db.add_all(prompts)
db.flush()

# ─── Agents ─────────────────────────────────────────────────────
agents = [
    Agent(
        name="代码助手",
        description="帮助开发者进行代码审查和 bug 分析",
        model_id=models[0].id,
        prompt_id=prompts[0].id,
        status=AgentStatus.ACTIVE,
    ),
    Agent(
        name="方案顾问",
        description="根据需求生成技术方案",
        model_id=models[1].id,
        prompt_id=prompts[2].id,
        status=AgentStatus.ACTIVE,
    ),
    Agent(
        name="测试 Agent（草稿）",
        description="这是一个草稿状态的 Agent，用于演示状态机",
        model_id=models[2].id,
        status=AgentStatus.DRAFT,
    ),
]
db.add_all(agents)
db.flush()

# ─── Skills ─────────────────────────────────────────────────────
skills = [
    Skill(
        name="代码执行器",
        description="安全执行代码片段并返回结果",
        endpoint_url="/api/v1/skills/execute",
        agent_id=agents[0].id,
    ),
    Skill(
        name="文档查询",
        description="查询技术文档和 API 参考",
        endpoint_url="/api/v1/skills/docs",
        agent_id=agents[0].id,
    ),
]
db.add_all(skills)

db.commit()
db.close()

print("Seed data created successfully!")
print(f"  Models:   {len(models)}")
print(f"  Prompts:  {len(prompts)}")
print(f"  Agents:   {len(agents)}")
print(f"  Skills:   {len(skills)}")
