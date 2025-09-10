# README

This is an example project to illustrate how to create log files and push them to Loki, a log aggregation system, either directly or via log collection tool named Promtail. Then we use Grafana to query, visualize, and alert on that data with interactive dashboards. We also use Logcli to access the data for custom scripting and automation. All these tools are designed to work nicely together. We will install them all locally without using Docker or Kubernetes.

## Install Loki

```shell
brew install logcli loki
brew services start loki
```

Make sure to get a "ready" from Loki, possibly after multiple attempts:

```shell
❯ curl http://localhost:3100/ready
Ingester not ready: waiting for 15s after being ready

❯ curl http://localhost:3100/ready
Pattern Ingester not ready: waiting for 15s after being ready

❯ curl http://localhost:3100/ready
ready
```

### Reduce Loki's log messages

To reduce the large amount of log messages created by Loki itself in `/opt/homebrew/var/log/loki.log` change the log level from `debug` to `warn` in `/opt/homebrew/etc/loki-local-config.yaml`:

```yaml
server:
  http_listen_port: 3100
  grpc_listen_port: 9096
  log_level: debug
```

Then restart loki:

```shell
brew services restart loki
```

### Use log rotation

To further reduce log file sizes in general, consider using proper logrotation to split and compress huge log files, shown here for Loki only:

```shell
% brew install logrotate

% cat > loki
/opt/homebrew/var/log/loki.log {
    size 100M
    rotate 5
    compress
    delaycompress
    copytruncate
    missingok
    notifempty
}

% sudo mv loki /opt/homebrew/etc/logrotate.d/loki

% brew services start logrotate
```

The values have the following effects:

* /opt/homebrew/var/log/loki.log: This is the log file to be rotated.
* size 100M: Rotates the log file when it grows larger than 100 megabytes.
* rotate 5: Keeps the last 5 rotated log files.
* compress: Compresses the rotated log files (usually with gzip).
* delaycompress: Delays compression of the most recent log file until the next rotation cycle.
* copytruncate: Copies the log file and then truncates the original in place. This ensures the Loki service can continue writing to the same file without needing to be restarted or signaled.
* missingok: Don't return an error if the log file doesn't exist.
* notifempty: Don't rotate the log if it's empty.


## Create log events

### Via Loki API

```shell
uv run pytest -s -v test_loki.py

logcli --quiet query '{app="pytest-test",source="test-runner"}' --since 15m --limit 5
logcli --quiet --output jsonl query '{app="pytest-test",source="test-runner"}' --since 15m --limit 5
```


### Via Promtail

Promtail is the official log collection agent for Loki that discovers and tails local log files, attaches identifying labels to the log streams, and ships them to a central Loki instance.

We will create a tool, `mac_stats.sh`, that runs periodically in the background to take some system measurements like CPU usage... and save them to a log file `/tmp/mac_stats.log`. Then we write a config, `promtail-local-config.yaml`, for promtail in order to obseve this log file, collect newly added entries and pass them to loki.

```shell
brew install promtail

cat > promtail-local-config.yaml
server:
  http_listen_port: 9080
  grpc_listen_port: 0

clients:
  - url: http://localhost:3100/loki/api/v1/push

scrape_configs:
- job_name: macbook_stats
  static_configs:
  - targets:
      - localhost
    labels:
      job: macbook_stats
      __path__: /tmp/mac_stats.log
  pipeline_stages:
  - json:
      expressions:
        component: component
        cpu_usage_percent: cpu_usage_percent
        memory_pressure_percent: memory_pressure_percent
        battery_percentage: battery_percentage
        power_source: power_source
  - labels:
      component:
      power_source:

uv run mac_stats.py &

sudo promtail -config.file=promtail-local-config.yaml

logcli --quiet query '{component="mac_stats"}' --since 1d --limit 5

pkill -f mac_stats.py
```

## Grafana

```shell
brew install grafana
brew services start grafana
```

More to come...
