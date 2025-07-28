"""Tests for the Pydantic-based configuration system."""

import os
from pathlib import Path
from unittest.mock import patch

import pytest
from pydantic import ValidationError

from clibro.config import APP_NAME, AppConfig, load_config


@pytest.fixture
def temp_config_file(tmp_path: Path) -> Path:
    """Create a temporary config file path."""
    config_dir = tmp_path / APP_NAME
    config_dir.mkdir()
    return config_dir / "config.toml"


def test_load_config_defaults() -> None:
    """Test that default configuration is loaded correctly."""
    with patch("clibro.config.get_config_path", return_value=Path("/nonexistent")):
        config = load_config()
        assert config.log_level == "INFO"
        assert config.log_file is None


def test_load_config_from_file(temp_config_file: Path) -> None:
    """Test that configuration is loaded from a TOML file."""
    temp_config_file.write_text('log_level = "WARNING"\nlog_file = "/var/log/uv.log"\n')
    with patch("clibro.config.get_config_path", return_value=temp_config_file):
        config = load_config()
        assert config.log_level == "WARNING"
        assert config.log_file == Path("/var/log/uv.log")


def test_config_precedence(temp_config_file: Path) -> None:
    """Test that environment variables override config file values."""
    temp_config_file.write_text('log_level = "WARNING"\n')
    with patch.dict(os.environ, {f"{APP_NAME.upper()}_LOG_LEVEL": "CRITICAL"}):
        with patch("clibro.config.get_config_path", return_value=temp_config_file):
            config = load_config()
            assert config.log_level == "CRITICAL"


def test_invalid_log_level() -> None:
    """Test that an invalid log level raises a validation error."""
    with pytest.raises(ValidationError):
        AppConfig(log_level="INVALID_LEVEL")


def test_config_path_override_cli(temp_config_file: Path) -> None:
    """Test that the --config flag correctly overrides the config path."""
    temp_config_file.write_text('log_level = "DEBUG"\n')
    config = load_config(config_path_override=temp_config_file)
    assert config.log_level == "DEBUG"


def test_config_path_override_env_var(temp_config_file: Path) -> None:
    """Test that the <APP_NAME>_CONFIG_PATH env var overrides the default path."""
    temp_config_file.write_text('log_level = "ERROR"\n')
    with patch.dict(os.environ, {f"{APP_NAME.upper()}_CONFIG_PATH": str(temp_config_file)}):
        config = load_config()
        assert config.log_level == "ERROR"
