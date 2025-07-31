# FastAPI Basic Starter

Below are the Markdown lines for badges representing FastAPI and uv, using the for-the-badge style consistent with your previous badges. Both FastAPI and uv have logos available in Shields.io via SimpleIcons, so these badges will include their respective logos. I’ve also included the updated full set of badges, incorporating FastAPI and uv alongside the existing ones (Docker, Terraform, Python, AWS, Bash, AWS EC2, AWS S3, Node.js, FastHTML, MonsterUI).
text
## Technologies Used
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/python-%2314354C.svg?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-%23009688.svg?style=for-the-badge&logo=fastapi&logoColor=white)
![uv](https://img.shields.io/badge/uv-%2300A3B0.svg?style=for-the-badge&logo=uv&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

A minimal FastAPI server demonstrating all common HTTP methods with tests.

![](assets/fastapi-basic-openapi.png)

## Setup and Usage

This project uses `uv` for dependency management.

1.  **Install dependencies:**

```bash
uv sync
```

2.  **Configure the port:**

Copy the example file to `.env` and then edit the desired local port in it.

```bash
cp .env.example .env
```

3.  **Run the server:**

```bash
source .env && uv run uvicorn main:app --port $PORT --reload
# or
uv run main.py
```

4.  **Smoke-test the Server:**

This is an example `curl` commands to test one API endpoint (you can run more when executing the file `test_curl.sh`).

```bash
# Get all items
curl -X GET http://127.0.0.1:8000/items
```

The server will be available like at `http://127.0.0.1:8000`. You can access the interactive API documentation at `http://127.0.0.1:8000/docs`.

## Run inside Docker

Build and run the application using Docker:

```bash
docker compose up -d
source .env && curl -X GET http://127.0.0.1:$PORT/items
./test_curl.sh
docker compose down
```

## Run Testsuite

This will run tests on a real server on a temporary free port.

```bash
❯ uv run pytest
====================== test session starts ======================
platform darwin -- Python 3.12.10, pytest-8.4.1, pluggy-1.6.0
rootdir: /path/to/fastapi-basic
configfile: pyproject.toml
plugins: anyio-3.7.1, asyncio-1.0.0
asyncio: mode=Mode.STRICT, asyncio_default_fixture_loop_scope=None, asyncio_default_test_loop_scope=function
collected 24 items

test_real.py ............                                 [ 50%]
test_testclient.py ............                           [100%]

====================== 24 passed in 2.80s =======================
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
