"""Gold layer: build the star schema (dimensions + facts) from silver."""
from .config import SQL_DIR
from .db import get_connection, run_sql_file
from .decorators import log_step
from .logger import get_logger

log = get_logger(__name__)

GOLD_TABLES = [
    "gold_dim_date",
    "gold_dim_customers",
    "gold_dim_sellers",
    "gold_dim_products",
    "gold_fact_sales",
    "gold_fact_payments",
]


@log_step
def load_gold():
    """Truncate + reload every gold table in ONE transaction (all or nothing)."""
    with get_connection() as conn:
        run_sql_file(conn, SQL_DIR / "gold" / "loading_gold_layer.sql")
        with conn.cursor() as cur:
            for table in GOLD_TABLES:
                cur.execute(f"select count(*) from gold.{table}")
                log.info("gold.%s loaded: %s rows", table, f"{cur.fetchone()[0]:,}")