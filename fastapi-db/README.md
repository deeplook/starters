# FastAPI DB

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/python-%2314354C.svg?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-%23009688.svg?style=for-the-badge&logo=fastapi&logoColor=white)
![uv](https://img.shields.io/badge/uv-%2300A3B0.svg?style=for-the-badge&logo=uv&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

A minimal FastAPI server with a simple database, demonstrating all common HTTP methods with tests, with decent configuration via environment variables or files.

![](assets/fastapi-basic-openapi.png)

## Setup and Usage

This project uses `uv` for dependency management.

1.  **Install dependencies:**

```bash
uv sync
```

2.  **Configure the config file:**

Copy the example file to `.env` and then edit to change the port or database URL if needed.

```bash
cp myapp.env.example myapp.env
```

3.  **Run the server:**

Use any of these commands:

```bash
source myapp.env && uv run uvicorn main:app --port $MYAPP_PORT
MYAPP_ENV_PATH=myapp.env uv run main.py
```

4.  **Smoke-test the Server:**

This is an example `curl` commands to test one API endpoint (you can run more when executing the file `test_curl.sh`).

```bash
# Get all items
❯ source myapp.env && curl -X GET http://127.0.0.1:$MYAPP_PORT/items
[]
```

The server will be available like at `http://127.0.0.1:$MYAPP_PORT`. You can access the interactive API documentation at `http://127.0.0.1:$MYAPP_PORT/docs`.

## Run inside Docker

Build and run the application using Docker:

```bash
docker compose up -d
source .env && curl -X GET http://127.0.0.1:$MYAPP_PORT/items
./test_curl.sh
docker compose down
```

## Run Testsuite

This will run tests on a real server on a temporary free port.

```bash
❯ MYAPP_ENV_PATH=myapp.test.env uv run pytest
============================ test session starts ============================
platform darwin -- Python 3.12.10, pytest-8.4.1, pluggy-1.6.0
rootdir: /path/to/fastapi-db
configfile: pyproject.toml
plugins: anyio-3.7.1, asyncio-1.0.0
asyncio: mode=Mode.STRICT, asyncio_default_fixture_loop_scope=None, asyncio_default_test_loop_scope=function
collected 22 items

test_real.py ............                                             [ 54%]
test_testclient.py ..........                                         [100%]

============================ 22 passed in 2.55s =============================
```

## Next Steps

Take this building block as a starting base to do things like the following:

- Add a FastAPI [middleware](https://fastapi.tiangolo.com/tutorial/middleware/) for logging or benchmarking.
- Add rate limitation with a package like [SlowAPI](https://slowapi.readthedocs.io/en/latest/).
- Integrate a database with [SQLModel](https://sqlmodel.tiangolo.com/) or [SQLAlchemy](https://www.sqlalchemy.org/) for data persistence.
- Add user authentication and authorization using [FastAPI's security utilities](https://fastapi.tiangolo.com/tutorial/security/).
- Implement more robust configuration management using [Pydantic's settings management](https://docs.pydantic.dev/latest/usage/settings/).
- Enable Cross-Origin Resource Sharing (CORS) with [CORSMiddleware](https://fastapi.tiangolo.com/tutorial/cors/) to allow frontend applications to interact with the API.
- Use [Background Tasks](https://fastapi.tiangolo.com/tutorial/background-tasks/) for long-running operations that don't need to be completed before the response is sent.
