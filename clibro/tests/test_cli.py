"""Tests for the command-line interface."""

import io
import json
import logging
import subprocess
import sys

from typer.testing import CliRunner

from clibro.cli import __version__, app
from clibro.config import APP_NAME

runner = CliRunner()


def test_inc_command() -> None:
    """Test the 'inc' command."""
    result = runner.invoke(app, ["inc", "2"])
    assert result.exit_code == 0
    assert "3" in result.stdout


def test_inc_command_json_output() -> None:
    """Test the 'inc' command with --format json."""
    result = runner.invoke(app, ["inc", "2", "--format", "json"])
    assert result.exit_code == 0
    json_output = json.loads(result.stdout)
    assert json_output == {"input": 2, "output": 3}


def test_version_flag() -> None:
    """Test the --version flag."""
    result = runner.invoke(app, ["--version"])
    assert result.exit_code == 0
    assert f"{APP_NAME} version: {__version__}" in result.stdout


def test_inc_command_with_invalid_input() -> None:
    """Test the 'inc' command with non-numeric input."""
    result = runner.invoke(app, ["inc", "abc"])
    assert result.exit_code != 0
    # Typer sends validation errors to stderr, not stdout.
    assert "Invalid value" in result.stderr
    assert "'abc' is not a valid integer" in result.stderr


def test_module_execution() -> None:
    """Test running the package as a module."""
    result = subprocess.run(
        [sys.executable, "-m", APP_NAME, "inc", "5"],
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0
    assert "6" in result.stdout


def test_verbose_logging() -> None:
    """Test that the --verbose flag enables debug logging."""
    log_stream = io.StringIO()
    # Get the application's logger
    logger = logging.getLogger(APP_NAME)
    # Add a new handler to capture log messages
    stream_handler = logging.StreamHandler(log_stream)
    stream_handler.setFormatter(logging.Formatter("%(levelname)s:%(name)s:%(message)s"))
    logger.addHandler(stream_handler)
    logger.setLevel(logging.DEBUG)

    try:
        runner.invoke(app, ["-v", "inc", "1"])
        log_output = log_stream.getvalue()

        assert f"DEBUG:{APP_NAME}:Verbose logging enabled." in log_output
        assert f"DEBUG:{APP_NAME}.core:Incrementing 1" in log_output
        assert f"INFO:{APP_NAME}.core:Performing increment operation." in log_output
        assert f"INFO:{APP_NAME}.cli:Increment command finished." in log_output
    finally:
        # Remove the handler to avoid interfering with other tests
        logger.removeHandler(stream_handler)
