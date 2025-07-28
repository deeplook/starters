"""Logging configuration for the project."""

import logging
from pathlib import Path

from .config import APP_NAME


def setup_logging(log_level: str, log_file: Path | None) -> None:
    """
    Set up the root logger for the application.

    Args:
        log_level: The logging level to use (e.g., "INFO", "DEBUG").
        log_file: The file to write logs to. If None, logs are sent to stderr.
    """
    logging.basicConfig(
        level=log_level,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        filename=str(log_file) if log_file else None,
        filemode="a" if log_file else "w",
    )
    logging.getLogger(APP_NAME).debug("Verbose logging enabled.")
