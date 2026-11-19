"""Command line entry point.

    python main.py init     # create schemas + tables (drops silver tables!)
    python main.py bronze   # CSV -> bronze
    python main.py silver   # bronze -> silver
    python main.py gold     # silver -> gold
    python main.py all      # bronze then silver then gold
"""
import argparse
import sys

from olist_etl.bronze import load_bronze
from olist_etl.db import init_db
from olist_etl.logger import get_logger
from olist_etl.silver import load_silver
from olist_etl.gold import load_gold       

log = get_logger("main")

COMMANDS = {
    "init": [init_db],
    "bronze": [load_bronze],
    "silver": [load_silver],
    "gold": [load_gold],
    "all": [load_bronze, load_silver,load_gold],
}


def main() -> int:
    parser = argparse.ArgumentParser(description="Olist ETL pipeline")
    parser.add_argument("command", choices=COMMANDS)
    args = parser.parse_args()
    try:
        for step in COMMANDS[args.command]:
            step()
    except Exception:
        log.error("Pipeline failed (see traceback above)")
        return 1
    log.info("Pipeline finished OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
