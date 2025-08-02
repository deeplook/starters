"""This module contains the configuration for the FastAPI server.

It reads environment variables to configure the application. The following
environment variables are required, and must be prefixed with `MYAPP_`:

- MYAPP_PORT: The port on which the FastAPI server will run.
- MYAPP_DATABASE_URL: The connection string for the application database.
- MYAPP_ENV_PATH: The path to the environment file. (optional)

There are two ways to provide these environment variables, namely by first
looking in an environment file found in the env. var. `MYAPP_ENV_PATH`
pointing to a file with values for `MYAPP_PORT` and `MYAPP_DATABASE_URL`,
and if that fails, then by looking up the variables in your shell environment:

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

from dotenv import dotenv_values


# Load environment variables from a file or from the environment.
MYAPP_ENV_PATH = os.getenv("MYAPP_ENV_PATH", "")
if MYAPP_ENV_PATH:
    # MYAPP_ENV_PATH=myapp.env uv run main.py
    # MYAPP_ENV_PATH=myapp.test.env uv run main.py
    if not os.path.exists(MYAPP_ENV_PATH):
        msg = (
            f"Error: File specified by MYAPP_ENV_PATH does not exist: {MYAPP_ENV_PATH}"
        )
        raise FileNotFoundError(msg)
    env = dotenv_values(MYAPP_ENV_PATH)
    env["MYAPP_ENV_PATH"] = MYAPP_ENV_PATH
else:
    # source myapp.env && uv run main.py
    # source myapp.test.env && uv run main.py
    env = {
        key: value
        for key, value in os.environ.items()
        if key.startswith("MYAPP_") and value != ""
    }
print(f"env: {env}")
if len(env) == 0:
    msg = "Error: No environment variables found with prefix MYAPP_"
    raise ValueError(msg)

MYAPP_PORT_STR = env.get("MYAPP_PORT")
if not MYAPP_PORT_STR:
    raise ValueError("Error: MYAPP_PORT environment variable not set.")
MYAPP_PORT = int(MYAPP_PORT_STR)

MYAPP_DATABASE_URL = env.get("MYAPP_DATABASE_URL")
if not MYAPP_DATABASE_URL:
    raise ValueError("Error: MYAPP_DATABASE_URL environment variable not set.")
