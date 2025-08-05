"""This module contains the configuration for the FastAPI server.

It reads environment variables to configure the application. The following
environment variables are required, and must be prefixed with `MYAPP_`:

- MYAPP_PORT: The port on which the FastAPI server will run.
- MYAPP_DATABASE_URL: The connection string for the application database.
- MYAPP_ENV_PATH: The path to the environment file. (optional)

There are two ways to provide these environment variables, namely by first
looking in an environment file found in the env. var. `MYAPP_ENV_PATH`
pointing to a file with values for `MYAPP_PORT` and `MYAPP_DATABASE_URL`,
and if that fails, then by looking up the variables in your shell environment.
The `.env` file is always prioritized over the shell environment variables.

1.  **Using an environment file:**
    Set the `MYAPP_ENV_PATH` environment variable to the path of a file
    containing the key-value pairs.

    Example for running the application:
    $ MYAPP_ENV_PATH=myapp.env uv run main.py

    Example for running tests:
    $ MYAPP_ENV_PATH=myapp.test.env pytest

2.  **Using shell environment variables:**
    Export the variables in your shell before running the application.
    Notice that the variables will be still defined in the environment
    after running the application/test.

    Example for running the application:
    $ source myapp.env
    $ uv run main.py

    Example for running tests:
    $ source myapp.test.env
    $ pytest
"""

import os
from typing import Tuple

from pydantic import ValidationError
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
)


class Settings(BaseSettings):
    """Pydantic settings class to manage configuration."""

    port: int
    database_url: str
    host: str = "0.0.0.0"
    reload: bool = False

    model_config = SettingsConfigDict(
        env_prefix="MYAPP_",
        env_file=os.getenv("MYAPP_ENV_PATH"),
        env_file_encoding="utf-8",
    )

    @classmethod
    def settings_customise_sources(
        cls,
        settings_cls: type[BaseSettings],
        init_settings: PydanticBaseSettingsSource,
        env_settings: PydanticBaseSettingsSource,
        dotenv_settings: PydanticBaseSettingsSource,
        file_secret_settings: PydanticBaseSettingsSource,
    ) -> Tuple[PydanticBaseSettingsSource, ...]:
        return (
            init_settings,
            dotenv_settings,
            env_settings,
            file_secret_settings,
        )


env_path = os.getenv("MYAPP_ENV_PATH")

# If MYAPP_ENV_PATH is set, we require the file to exist.
if env_path and not os.path.exists(env_path):
    raise FileNotFoundError(
        f"The specified environment file does not exist: {env_path}"
    )

try:
    settings = Settings()  # type: ignore[call-arg]
except ValidationError as e:
    # Catch Pydantic's validation error and raise a more user-friendly
    # exception that lists all required environment variables.
    required_vars = ["MYAPP_PORT", "MYAPP_DATABASE_URL"]
    error_message = (
        "Configuration error: Missing or invalid required settings.\n"
        "Please provide the following environment variables, either in a file "
        "pointed to by MYAPP_ENV_PATH or as shell environment variables:"
    )
    error_message += "\n- " + "\n- ".join(required_vars)
    raise ValueError(error_message) from e
