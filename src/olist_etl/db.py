"""Database helpers: connection, running .sql files, one-time schema setup."""
from contextlib import contextmanager
from pathlib import Path

import psycopg2

from .config import DB_CONFIG, SQL_DIR
from .decorators import log_step, retry
from .logger import get_logger

log = get_logger(__name__)


@retry(max_attempts=3, delay=3)
def _connect():
    return psycopg2.connect(**DB_CONFIG)


@contextmanager
def get_connection():
    """Yield a connection. Commit on success, rollback on any error, always close."""
    conn = _connect()
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()


def run_sql_file(conn, path: Path) -> int:
    """Execute a whole .sql file. Returns the row count of its last statement."""
    sql = Path(path).read_text(encoding="utf-8")
    with conn.cursor() as cur:
        cur.execute(sql)
        return cur.rowcount


@log_step
def init_db():
    """Create schemas and bronze/silver tables.

    WARNING: ddl_silver.sql DROPs and recreates the silver tables, so run this
    once (or when the table structure changes), not on every pipeline run.
    """
    with get_connection() as conn:
        with conn.cursor() as cur:
            for schema in ("bronze", "silver", "gold"):
                cur.execute(f"create schema if not exists {schema}")
        run_sql_file(conn, SQL_DIR / "bronze" / "creating_bronze_table.sql")
        run_sql_file(conn, SQL_DIR / "silver" / "ddl_silver.sql")
    log.info("Schemas and tables created")
