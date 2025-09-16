# FastAPI DB

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/python-%2314354C.svg?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-%23009688.svg?style=for-the-badge&logo=fastapi&logoColor=white)
![uv](https://img.shields.io/badge/uv-%2300A3B0.svg?style=for-the-badge&logo=uv&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

A minimal FastAPI server with a simple database, demonstrating all common HTTP methods with tests, with decent configuration via environment variables or files.

![](assets/fastapi-basic-openapi.png)

## Project Structure

The project is organized as follows:

```
.
├── src
│   ├── __init__.py
│   ├── cli.py
│   ├── config.py
│   ├── crud.py
│   ├── database.py
│   ├── main.py
│   ├── models.py
│   └── schemas.py
├── tests
│   ├── conftest.py
│   ├── test_config.py
│   ├── test_curl.sh
│   ├── test_real.py
│   └── test_testclient.py
├── .dockerignore
├── .gitignore
├── .python-version
├── docker-compose.yml
├── Dockerfile
├── Makefile
├── myapp.env.example
├── myapp.test.env.example
├── NOTES.txt
├── pyproject.toml
└── README.md
```

## Setup and Usage

This project uses `uv` for dependency management.

1.  **Install dependencies:**
    ```bash
    uv sync
    ```

2.  **Configure the application:**
    The application is configured via an environment file. You can copy the provided example file:
    ```bash
    cp myapp.env.example myapp.env
    ```
    Then, set the `MYAPP_ENV_PATH` variable to point to it:
    ```bash
    export MYAPP_ENV_PATH=myapp.env
    ```

3.  **Run the server:**
    The application now uses a CLI. You can start and stop the server with these commands:
    ```bash
    # Start the server
    make start-local

    # Stop the server
    make stop-local
    ```
    The server will be available at `http://127.0.0.1:PORT`, where `PORT` is defined in your `.env` file. You can access the interactive API documentation at `http://127.0.0.1:PORT/docs`.

## Makefile

This project includes a `Makefile` with the following primary targets:

- `make help`: Display the help screen.
- `make start-local`: Start the application locally.
- `make stop-local`: Stop the locally running application.
- `make docker-up`: Build and start the application in a Docker container.
- `make docker-down`: Stop the Docker containers.
- `make test`: Run the `pytest` test suite.
- `make test-curl`: Run `curl`-based integration tests against a running server.
- `make clean`: Remove temporary build files.

## Running with Docker

Build and run the application using Docker:

```bash
# Set the environment file path
export MYAPP_ENV_PATH=myapp.env

# Build and start the container in the background
make docker-up

# Run tests against the container
make test-curl

# Stop and remove the container
make docker-down
```

## Running the Test Suite

There are two ways to run the tests:

1.  **Unit & Integration Tests (`pytest`):**
    This runs the full suite of tests, including configuration and database logic, without needing a running server.
    ```bash
    make test
    ```

2.  **End-to-End Tests (`curl`):**
    This script runs a series of `curl` commands to test the full application lifecycle against a running server. It automatically clears the database at the start to ensure a clean run.

    First, start the server in one terminal:
    ```bash
    export MYAPP_ENV_PATH=myapp.env
    make start-local
    ```

    Then, in another terminal, run the tests:
    ```bash
    make test-curl
    ```

## Next Steps

Take this building block as a starting base to do things like the following:

- Add a MCP server wrapping the FastAPI app to make its endpoints available inside a chat with LLM models.
- Add a FastAPI [middleware](https://fastapi.tiangolo.com/tutorial/middleware/) for logging or benchmarking.
- Add rate limitation with a package like [SlowAPI](https://slowapi.readthedocs.io/en/latest/).
- Add user authentication and authorization using [FastAPI's security utilities](https://fastapi.tiangolo.com/tutorial/security/).
- Implement more robust configuration management using [Pydantic's settings management](https://docs.pydantic.dev/latest/usage/settings/).
- Enable Cross-Origin Resource Sharing (CORS) with [CORSMiddleware](https://fastapi.tiangolo.com/tutorial/cors/) to allow frontend applications to interact with the API.
- Use [Background Tasks](https://fastapi.tiangolo.com/tutorial/background-tasks/) for long-running operations that don't need to be completed before the response is sent.

The MCP server is already implemented. But you have to install some interface (desktop or CLI) to an LLM model. This was tested with Gemini and one entr in its settings like this:

```shell
❯ cat ~/.gemini/settings.json
{
    "theme": "Default",
    "selectedAuthType": "gemini-api-key",
    "hasSeenIdeIntegrationNudge": true,
    "ideMode": true,
    "mcpServers": {
        "fastapi-db-mcp": {
            "url": "http://localhost:8002/mcp"
        }
    }
}
```

Then inside Gemini CLI you can run queries like e.g.:

```
❯ gemini
[...]

> Add a new item with name "Napoleon" and description "Bonaparte".

 ✓  create_item_items_post (fastapi-db-mcp MCP Server) {"name":"Napoleon","description":"Bonaparte"}
    {
        "name": "Napoleon",
        "id": 2,
        "description": "Bonaparte"
    }

> Modify item with name "Napolean" and set description to "Elba".

I believe you meant to modify the item with the name "Napoleon". I will proceed with this change.
[...]
I have modified the item with ID 2 and set the description to "Elba".

> Read that item.

[...]
✦ OK. Here is the item:
   - Name: Napoleon, ID: 2, Description: Elba
```
