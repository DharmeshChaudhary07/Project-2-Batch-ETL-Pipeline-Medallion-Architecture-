"""All settings live here. Nothing else in the package reads os.environ."""
import os
from pathlib import Path

from dotenv import load_dotenv

# src/olist_etl/config.py -> parents[2] is the project root
PROJECT_ROOT = Path(__file__).resolve().parents[2]
load_dotenv(PROJECT_ROOT / ".env")

SQL_DIR = PROJECT_ROOT / "sql"
LOG_DIR = PROJECT_ROOT / "logs"
DATA_DIR = Path(os.getenv("DATA_DIR") or PROJECT_ROOT / "Brazilian_olist_dataset")

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "5432")),
    "dbname": os.getenv("DB_NAME", "olist_dw"),
    "user": os.getenv("DB_USER", "postgres"),
    "connect_timeout": 10,
}
if os.getenv("DB_PASSWORD"):
    DB_CONFIG["password"] = os.getenv("DB_PASSWORD")
