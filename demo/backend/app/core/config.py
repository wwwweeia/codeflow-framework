import os

PROJECT_NAME: str = "AI Prompt Lab"
VERSION: str = "1.0.0"
API_PREFIX: str = "/api/v1"

# SQLite 文件路径，与项目根目录对齐
DB_PATH: str = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "prompt_lab.db")
DATABASE_URL: str = f"sqlite:///{DB_PATH}"
