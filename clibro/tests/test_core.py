"""Tests for the core business logic."""

import pytest

from clibro.core import increment


def test_increment() -> None:
    """Test the increment function with valid input."""
    assert increment(2) == 3


def test_increment_with_invalid_input() -> None:
    """Test the increment function with non-integer input."""
    with pytest.raises(TypeError, match="Input must be an integer."):
        increment("a")  # type: ignore
