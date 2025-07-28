# Logging

When using `{{ project }}` as a library, it's important to understand that it does *not* configure logging on its own. This is by design, so it doesn't interfere with the host application's logging setup. The host application is responsible for configuring the logging system.

The `examples/app.py` file demonstrates how to set up a basic logger that captures the library's output.

## Structured Logging

For more advanced use cases, the library's log messages include structured context via the `extra` dictionary. This allows a host application to process machine-readable log data, for example by using a JSON logger.

The `examples/structured_app.py` file demonstrates how to do this using the `python-json-logger` library.

**To run the examples:**

1.  Make sure you have the package and its development dependencies installed (`make install`).
2.  Run the scripts:
    ```bash
    # Basic logging example
    uv run python examples/app.py

    # Structured JSON logging example
    uv run python examples/structured_app.py
    ```
