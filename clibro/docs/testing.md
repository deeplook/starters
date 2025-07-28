# Testing Strategy

This project employs a multi-layered testing strategy to ensure code quality, correctness, and the reliability of our continuous integration (CI) pipeline.

## Unit and Integration Tests

We use the `pytest` framework for writing and running our tests. All tests are located in the `tests/` directory and follow the standard `test_*.py` naming convention. Our strategy includes both unit and integration tests.

### Unit Tests

Unit tests focus on the smallest piece of code, typically a single function, in complete isolation. All external dependencies are "mocked" or avoided. This makes them very fast.

A good example is `tests/test_core.py`, which tests the `increment` function without depending on any other part of the application.

### Integration Tests

Integration tests verify that different parts of the system work together correctly. They are broader and test the interaction between modules, the filesystem, or external tools.

Examples in this project include:
- `tests/test_cli.py`: Tests the integration between the command-line interface and the core application logic.
- `tests/test_config.py`: Tests the integration of the configuration module with the filesystem.

### Running Tests

To run the complete test suite, use the following command:

```bash
make test
```

This command will execute all tests and provide a coverage report, indicating the percentage of the codebase that is covered by tests.

## CI Workflow Simulation

To prevent issues in our CI pipeline, we use `act` to simulate the GitHub Actions workflow locally. This allows us to catch potential problems before they are pushed to the main repository.

### Running the Local Workflow

To run the local CI workflow simulation, use the following command:

```bash
make workflow
```

This command will execute the entire CI pipeline as defined in `.github/workflows/ci.yml`, including linting, testing, and building the package.

## Makefile Tests

The project's `Makefile` itself is tested to ensure that its targets behave as expected. These tests are located in `tests/test_makefile.py`.

To avoid any side effects on the local development environment, these tests are run in an isolated, temporary directory. This ensures that commands like `make clean` and `make distclean` do not accidentally delete the developer's virtual environment or other important files.
