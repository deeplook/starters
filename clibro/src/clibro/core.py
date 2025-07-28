"""Core business logic for the project."""

import logging

logger = logging.getLogger(__name__)


def increment(x: int) -> int:
    """
    Increment a number by 1.

    Args:
        x: The integer to increment.

    Returns:
        The incremented number.

    Raises:
        TypeError: If the input is not an integer.
    """
    if not isinstance(x, int):
        raise TypeError("Input must be an integer.")
    logger.debug("Incrementing %d", x)

    log_context = {"input_value": x, "operation": "increment"}
    logger.info("Performing increment operation.", extra=log_context)

    return x + 1
