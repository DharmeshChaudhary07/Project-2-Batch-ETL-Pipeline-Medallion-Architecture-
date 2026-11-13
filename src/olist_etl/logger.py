"""One-time logging setup: console + rotating file (logs/etl.log)."""
import logging
import sys
from logging.handlers import RotatingFileHandler

from .config import LOG_DIR

_BASE = "olist_etl"
_configured = False


def _configure() -> None:
    global _configured
    if _configured:
        return
    LOG_DIR.mkdir(exist_ok=True)
    base = logging.getLogger(_BASE)
    base.setLevel(logging.INFO)
    base.propagate = False
    fmt = logging.Formatter("%(asctime)s | %(levelname)-8s | %(name)s | %(message)s")

    console = logging.StreamHandler(sys.stdout)
    console.setFormatter(fmt)
    base.addHandler(console)

    file_handler = RotatingFileHandler(
        LOG_DIR / "etl.log", maxBytes=2_000_000, backupCount=3, encoding="utf-8"
    )
    file_handler.setFormatter(fmt)
    base.addHandler(file_handler)
    _configured = True


def get_logger(name: str) -> logging.Logger:
    """Use as: log = get_logger(__name__)"""
    _configure()
    if not name.startswith(_BASE):
        name = f"{_BASE}.{name}"
    return logging.getLogger(name)
