"""
This module contains tests for the configuration loading logic.
"""

import os
import subprocess
import sys


def run_config_test(env):
    """Helper function to run config.py with a given environment."""
    # The command to run, which will import the config module
    command = [sys.executable, "-c", "import config"]

    # Run the command with the specified environment
    result = subprocess.run(
        command, env=env, capture_output=True, text=True, check=False
    )
    return result


def test_missing_env_file():
    """
    Tests that the application raises FileNotFoundError when MYAPP_ENV_PATH
    points to a non-existent file.
    """
    env = os.environ.copy()
    env["MYAPP_ENV_PATH"] = "non_existent_file.env"

    result = run_config_test(env)

    assert result.returncode != 0
    assert "FileNotFoundError" in result.stderr
    assert "non_existent_file.env" in result.stderr


def test_missing_env_vars():
    """
    Tests that the application raises ValueError when required environment
    variables are not set.
    """
    # Create a temporary empty .env file to avoid FileNotFoundError
    with open("empty.env", "w", encoding="utf-8") as f:  # noqa: F841
        pass

    env = os.environ.copy()
    env["MYAPP_ENV_PATH"] = "empty.env"
    # Unset the required variables
    if "MYAPP_PORT" in env:
        del env["MYAPP_PORT"]
    if "MYAPP_DATABASE_URL" in env:
        del env["MYAPP_DATABASE_URL"]

    result = run_config_test(env)

    assert result.returncode != 0
    assert "ValueError" in result.stderr
    assert "MYAPP_PORT" in result.stderr
    assert "MYAPP_DATABASE_URL" in result.stderr

    # Clean up the temporary file
    os.remove("empty.env")


def test_valid_config_from_file():
    """
    Tests that the application loads configuration correctly from a .env file.
    """
    # Create a temporary .env file with valid settings
    with open("valid.env", "w", encoding="utf-8") as f:
        f.write("MYAPP_PORT=8000\n")
        f.write("MYAPP_DATABASE_URL=sqlite:///./test.db\n")

    env = os.environ.copy()
    env["MYAPP_ENV_PATH"] = "valid.env"

    result = run_config_test(env)

    assert result.returncode == 0
    assert result.stderr == ""

    # Clean up the temporary file
    os.remove("valid.env")


def test_valid_config_from_shell():
    """
    Tests that the application loads configuration correctly from shell
    environment variables.
    """
    env = os.environ.copy()
    env["MYAPP_PORT"] = "8001"
    env["MYAPP_DATABASE_URL"] = "sqlite:///./shell.db"
    # Ensure MYAPP_ENV_PATH is not set, so it falls back to shell variables
    if "MYAPP_ENV_PATH" in env:
        del env["MYAPP_ENV_PATH"]

    result = run_config_test(env)

    assert result.returncode == 0
    assert result.stderr == ""
