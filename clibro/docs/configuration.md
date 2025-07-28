# Configuration

The application's behavior is configured using a layered system that provides a high degree of flexibility. The system uses [Pydantic](https://pydantic.dev/) for robust validation and settings management.

## Configuration Layers

Configuration is loaded from the following sources, in order of increasing precedence (later sources override earlier ones):

1.  **Command-Line Arguments**: e.g., `--config` or `--verbose` (highest priority)
2.  **Environment Variables**
3.  **Global TOML Configuration File**
4.  **Default Values** (lowest priority)

Any setting can be configured via a TOML file or a corresponding environment variable. Environment variables will always override values set in the configuration file.

## Configuration Options

| Setting             | TOML Key          | Environment Variable         | CLI Flag                | Default Value            | Description                                                                 |
| :------------------ | :---------------- | :--------------------------- | :---------------------- | :----------------------- | :-------------------------------------------------------------------------- |
| **Config Path**     | (none)            | `CLIBRO_CONFIG_PATH`        | `--config`              | (OS-specific)            | Overrides the default path to the `config.toml` file.                       |
| **Log Level**       | `log_level`       | `CLIBRO_LOG_LEVEL`          | `-v`, `--verbose`       | `"INFO"`                 | The logging level (`DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`).          |
| **Log File**        | `log_file`        | `CLIBRO_LOG_FILE`           | (none)                  | `null` (logs to console) | The path to a file where logs should be written.                            |

## Configuration File

The application uses the `platformdirs` library to find the appropriate user-level configuration directory for the current operating system (e.g., `~/.config/{{ project }}` on Linux, `~/Library/Application Support/{{ project }}` on macOS, or `C:\Users\<user>\AppData\Roaming\{{ project }}` on Windows).

To find the exact path for your system, run:

```bash
clibro config show
```

This command will display the active configuration values and the location where it expects to find a `config.toml` file. A `config.toml.example` file is included in the root of this repository to use as a template.


```{parsed-literal}
:class: language-python
print("Hello from {{ project }} {{ release }}")
```
