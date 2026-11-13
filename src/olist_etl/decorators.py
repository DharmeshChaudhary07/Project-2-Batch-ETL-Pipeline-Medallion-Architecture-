"""Reusable decorators: @log_step (timing + errors) and @retry (transient failures)."""
import functools
import time

import psycopg2

from .logger import get_logger

log = get_logger(__name__)


def log_step(func):
    """Log START / DONE (with seconds) / FAILED (with traceback) around a function."""

    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        log.info("START %s", func.__name__)
        t0 = time.perf_counter()
        try:
            result = func(*args, **kwargs)
        except Exception:
            log.exception("FAILED %s after %.2fs", func.__name__, time.perf_counter() - t0)
            raise
        log.info("DONE  %s in %.2fs", func.__name__, time.perf_counter() - t0)
        return result

    return wrapper


def retry(max_attempts=3, delay=5, backoff=2, exceptions=(psycopg2.OperationalError,)):
    """Retry only on transient errors (default: DB connection problems).

    A SQL syntax error or bad data is NOT retried: it would fail the same way again.
    """

    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            wait = delay
            for attempt in range(1, max_attempts + 1):
                try:
                    return func(*args, **kwargs)
                except exceptions as exc:
                    if attempt == max_attempts:
                        log.error("%s failed after %d attempts: %s", func.__name__, attempt, exc)
                        raise
                    log.warning(
                        "%s attempt %d/%d failed (%s). Retrying in %ss",
                        func.__name__, attempt, max_attempts, str(exc).strip(), wait,
                    )
                    time.sleep(wait)
                    wait *= backoff

        return wrapper

    return decorator
