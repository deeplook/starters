"""Configuration management for the project using Pydantic."""

import os
import tomllib
from pathlib import Path
from typing import Literal

from platformdirs import user_config_dir
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

try:
    # Read from pyproject.toml in development
    pyproject_path = Path(__file__).parent.parent.parent / "pyproject.toml"
    with pyproject_path.open("rb") as f:
        data = tomllib.load(f)
    APP_NAME = data["project"]["name"]
except (FileNotFoundError, KeyError):
    # Fallback for when package is installed
    # Assumes package name is the same as the app name
    APP_NAME = __package__.split(".")[0]

CONFIG_FILE_NAME = "config.toml"


def get_config_path() -> Path:
    """
    Get the path to the global configuration file, respecting the <APP_NAME>_CONFIG_PATH env var.
    """
    if path_str := os.environ.get(f"{APP_NAME.upper()}_CONFIG_PATH"):
        return Path(path_str)
    return Path(user_config_dir(APP_NAME, roaming=True)) / CONFIG_FILE_NAME


def read_toml_config(path: Path) -> dict:
    """Read a TOML file and return its contents as a dictionary."""
    if not path.exists():
        return {}
    with path.open("rb") as f:
        return tomllib.load(f)


class AppConfig(BaseSettings):
    """
    Application configuration model.

    Defines the configuration schema and loads settings from various sources.
    """

    model_config = SettingsConfigDict(
        env_prefix=f"{APP_NAME.upper()}_",
        case_sensitive=False,
    )

    log_level: Literal["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"] = Field(
        default="INFO", description="The logging level."
    )
    log_file: Path | None = Field(default=None, description="Path to the log file. If None, logs to stderr.")


def load_config(config_path_override: Path | None = None) -> AppConfig:
    """
    Load configuration from multiple sources with a defined precedence.

    The loading order of precedence is:
    1. Environment Variables
    2. Global TOML Configuration File
    3. Default Values (defined in the model)
    """
    # Load from global TOML file as the base
    global_config_path = config_path_override or get_config_path()
    config_data = read_toml_config(global_config_path)

    # Manually override with any set environment variables
    log_level_env = f"{APP_NAME.upper()}_LOG_LEVEL"
    log_file_env = f"{APP_NAME.upper()}_LOG_FILE"
    if log_level_env in os.environ:
        config_data["log_level"] = os.environ[log_level_env]
    if log_file_env in os.environ:
        config_data["log_file"] = os.environ[log_file_env]

    # Create the final, validated config from the merged data.
    # Pydantic will use its defaults for any keys not in the merged_data.
    return AppConfig(**config_data)


# Create a single config instance to be used throughout the application
config = load_config()
