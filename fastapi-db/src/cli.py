"""This module contains the command-line interface for the application."""

import subprocess
import typer
import uvicorn

from main import app
from src.config import settings


def _stop_server(port: int):
    """Stops the server running on the specified port."""
    print(f"Attempting to stop server on port {port}...")
    try:
        # Find and kill the process listening on the specified port
        subprocess.run(
            f"lsof -t -i:{port} | xargs kill -9",
            shell=True,
            check=True,
            capture_output=True,
        )
        print(f"Server on port {port} stopped successfully.")
    except subprocess.CalledProcessError:
        print(f"No process found running on port {port}.")


def cli():
    """The main command-line interface function."""
    typer_app = typer.Typer()

    @typer_app.command()
    def start(
        host: str = typer.Option(settings.host, help="The host to bind to."),
        port: int = typer.Option(settings.port, help="The port to bind to."),
        reload: bool = typer.Option(settings.reload, help="Enable auto-reloading."),
    ):
        """Starts the FastAPI server."""
        print(f"Starting server on {host}:{port}...")
        uvicorn.run(
            app,
            host=host,
            port=port,
            reload=reload,
        )

    @typer_app.command()
    def stop():
        """Stops the FastAPI server."""
        _stop_server(settings.port)

    typer_app()
