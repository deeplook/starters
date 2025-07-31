[![CI](https://github.com/deeplook/starters/actions/workflows/ci.yml/badge.svg)](https://github.com/deeplook/starters/actions/workflows/ci.yml)
[![Ruff](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json)](https://github.com/astral-sh/ruff)

# Clibro

![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/python-%2314354C.svg?style=for-the-badge&logo=python&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-%23009688.svg?style=for-the-badge&logo=fastapi&logoColor=white)
![uv](https://img.shields.io/badge/uv-%2300A3B0.svg?style=for-the-badge&logo=uv&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)

This is a minimal Python project illustrating how to structure some minimal amount of Python code, and use this functionality as a library, and via an entry point also as a CLI command.

## How to Work on This Project (For a New Developer)

If you are a developer who wants to contribute to this project, you'll want to set up a local development environment. This allows you to edit the code, run tests, and see your changes immediately.

**Goal:** To install the package in "editable" mode, where changes to the source code are instantly reflected in your environment without needing to reinstall.

**Steps:**

1.  **Clone the Repository:**
    First, get a local copy of the code.
    ```bash
    git clone <repository-url>
    cd clibro
    ```

2.  **Create and Activate a Virtual Environment:**
    It's crucial to work in an isolated Python environment.
    ```bash
    uv venv
    source .venv/bin/activate
    ```

3.  **Install Dependencies and Pre-commit Hooks:**
    This single command installs all necessary development dependencies and sets up the pre-commit hooks to ensure code quality.
    ```bash
    make install
    ```

> **What does "Editable Mode" actually do?**
> The `make install` command uses `uv pip install -e .`. The `-e` flag is for an "editable" install. Instead of copying the source code to your virtual environment's `site-packages` directory, it creates a special link file (a `.pth` file). This file simply contains the absolute path to your project's `src` directory. When Python starts, it adds this path to `sys.path`, so it knows to find the `clibro` package by looking directly at your source files. This is how you can edit the code and have the changes take effect immediately without reinstalling.

4.  **Verify the Setup:**
    Run the linters and tests to ensure everything is working correctly.
    ```bash
    make lint && make test
    ```

## How to Use This Package (For a User)

There are two primary ways to use this package: as a library in a specific project, or as a globally available command-line tool.

### 1. As a Library in a Project

If you want to use `clibro`'s functions in your own Python code, you should install it into your project's virtual environment.

**Steps:**

1.  **Build the Package:**
    From the `clibro` source directory, run:
    ```bash
    make dist
    ```
    This creates a distributable "wheel" file in the `dist/` directory (e.g., `dist/clibro-0.1.0-py3-none-any.whl`).

2.  **Install the Wheel File:**
    In your own project's virtual environment, install the wheel file.

    **Using `uv`:**
    ```bash
    uv pip install /path/to/dist/clibro-0.1.0-py3-none-any.whl
    ```

    **Using standard `pip`:**
    ```bash
    pip install /path/to/dist/clibro-0.1.0-py3-none-any.whl
    ```

### 2. As a Global Command-Line Tool

If you want to use the `clibro` command from anywhere on your system without activating a virtual environment, you should install it as a "tool". This is the modern, safe alternative to a global install, as it prevents dependency conflicts.

**How it works:** `uv tool install` installs the package into its own isolated virtual environment and adds the command to your system's `PATH`.

**Steps:**

1.  **Build the Package:**
    First, create the wheel file if you haven't already:
    ```bash
    make dist
    ```

2.  **Install with `uv`:**
    Use the `uv tool install` command, pointing it to your package.
    ```bash
    uv tool install clibro --from dist/clibro-0.1.0-py3-none-any.whl
    ```
    > **Note:** The first time you run this, `uv` may instruct you to add its tool `bin` directory to your shell's `PATH`. Follow the on-screen instructions.

3.  **Verify the Installation:**
    You can now run the command from any terminal window.
    ```bash
    clibro --help
    ```

4.  **Managing Tools:**
    You can easily manage your installed tools.
    ```bash
    # List all installed tools
    uv tool list

    # Uninstall a tool
    uv tool uninstall clibro
    ```

### 3. Programmatic Usage

When using `clibro` as a library, the host application is responsible for configuring the logging system. For more details, see the [logging documentation](docs/logging.md).

## Makefile Targets

This project uses a `Makefile` to automate common tasks.

- `make install`: Installs dependencies and pre-commit hooks.
- `make uninstall`: Uninstalls the package from the local virtual environment.
- `make test`: Runs the test suite.
- `make lint`: Runs the linter and formatter.
- `make dist`: Builds the package for distribution.
- `make clean`: Removes temporary build files.
- `make distclean`: Removes all temporary files and the virtual environment.

## Configuration

For details on how to configure the application, please see the [configuration documentation](docs/configuration.md).

## Code Style and Quality

This project uses a number of tools and packages to ensure a certain level for the code style and quality.

- **`ruff`**: For linting and formatting.
- **`mypy`**: For static type checking.
- **`pre-commit`**: To run checks before each commit.
- **`pathlib`**: All file paths are handled using `pathlib.Path`.
- **Docstrings**: All modules must have docstrings.
