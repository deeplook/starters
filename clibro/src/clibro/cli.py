"""Command-line interface for the project."""

import importlib.metadata
import json
import logging
from enum import Enum
from pathlib import Path
from typing import Optional

import typer
from typing_extensions import Annotated

from .config import APP_NAME, get_config_path, load_config
from .core import increment
from .log import setup_logging

app = typer.Typer()
config_app = typer.Typer(name="config", help="Manage the application configuration.")
app.add_typer(config_app)

__version__ = importlib.metadata.version(APP_NAME)
logger = logging.getLogger(__name__)


class OutputFormat(str, Enum):
    text = "text"
    json = "json"


def version_callback(value: bool) -> None:
    """Prints the version of the package."""
    if value:
        print(f"{APP_NAME} version: {__version__}")
        raise typer.Exit()


@app.callback()
def main(
    version: Annotated[
        Optional[bool],
        typer.Option(
            "--version",
            callback=version_callback,
            is_eager=True,
            help="Show the version and exit.",
        ),
    ] = None,
    config_path: Annotated[
        Optional[Path],
        typer.Option(
            "--config",
            help="Path to the configuration file.",
            exists=True,
            dir_okay=False,
            resolve_path=True,
        ),
    ] = None,
    verbose: Annotated[
        Optional[bool],
        typer.Option(
            "-v",
            "--verbose",
            help="Enable verbose logging. Overrides config file and environment variables.",
        ),
    ] = None,
) -> None:
    """A minimal example Python project to be used as a library and shell command."""
    config = load_config(config_path_override=config_path)
    log_level = config.log_level
    if verbose:
        log_level = "DEBUG"

    setup_logging(log_level, config.log_file)


@app.command()
def inc(
    number: int,
    format: Annotated[
        OutputFormat,
        typer.Option(case_sensitive=False, help="Output format."),
    ] = OutputFormat.text,
) -> None:
    """Increment a number by 1."""
    result = increment(number)
    log_context = {"input": number, "output": result}
    logger.info("Increment command finished.", extra=log_context)
    if format == OutputFormat.json:
        print(json.dumps({"input": number, "output": result}))
    else:
        print(result)


@config_app.command("show")
def show_config(
    config_path: Annotated[
        Optional[Path],
        typer.Option(
            "--config",
            help="Path to the configuration file.",
            exists=True,
            dir_okay=False,
            resolve_path=True,
        ),
    ] = None,
) -> None:
    """Show the current configuration."""
    config = load_config(config_path_override=config_path)
    config_path = get_config_path()
    print("Configuration:")
    print(f"  Log Level: {config.log_level}")
    print(f"  Log File: {config.log_file or 'Not set (logs to console)'}")
    print(f'\nConfiguration file path: "{config_path}" (exists: {config_path.exists()})')
