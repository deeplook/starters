"""Tests configuration foptions vie the command-line interface."""

from typer.testing import CliRunner

from clibro.cli import app
from clibro.config import APP_NAME

runner = CliRunner()


def test_config_show_info() -> None:
    """Test the 'config show' command."""
    result = runner.invoke(app, ["config", "show"])
    assert result.exit_code == 0
    print(result.stdout)
    assert "INFO" in result.stdout


def test_config_show_debug() -> None:
    """Test the 'config show' command with <APP_NAME>_LOG_LEVEL prefix."""
    result = runner.invoke(app, ["config", "show"], env={f"{APP_NAME.upper()}_LOG_LEVEL": "DEBUG"})
    assert result.exit_code == 0
    print(result.stdout)
    assert "DEBUG" in result.stdout
