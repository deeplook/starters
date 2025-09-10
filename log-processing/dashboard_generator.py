#!/usr/bin/env python3

import json

from grafanalib.core import (
    Dashboard,
    GridPos,
    TimeSeries,
    Target,
)
from grafanalib._gen import DashboardEncoder


def main():
    """Generates a Grafana dashboard and saves it to a file."""

    dashboard = Dashboard(
        title="MacBook Stats",
        description="Dashboard for monitoring MacBook performance metrics",
        timezone="browser",
        panels=[
            TimeSeries(
                id=1,
                title="CPU Usage",
                dataSource="Loki",  # Assumes a Loki datasource named 'Loki'
                targets=[
                    Target(
                        expr='sum(avg_over_time({job="macbook_stats"} | json | unwrap cpu_usage_percent [$__interval]))',
                        legendFormat="CPU Usage (%)",
                    ),
                ],
                gridPos=GridPos(h=8, w=12, x=0, y=0),
                unit="percent",
            ),
            TimeSeries(
                id=2,
                title="Memory Free",
                dataSource="Loki",
                targets=[
                    Target(
                        expr='sum(avg_over_time({job="macbook_stats"} | json | unwrap memory_free_percent [$__interval]))',
                        legendFormat="Memory Free (%)",
                    ),
                ],
                gridPos=GridPos(h=8, w=12, x=12, y=0),
                unit="percent",
            ),
            TimeSeries(
                id=3,
                title="Battery Percentage",
                dataSource="Loki",
                targets=[
                    Target(
                        expr='avg_over_time({job="macbook_stats"} | json | unwrap battery_percentage [$__interval]) by (power_source)',
                        legendFormat="{{power_source}}",
                    ),
                ],
                gridPos=GridPos(h=8, w=24, x=0, y=8),
                unit="percent",
            ),
        ],
    )

    # Serialize to JSON
    dashboard_json = json.dumps(
        dashboard.to_json_data(), sort_keys=True, indent=2, cls=DashboardEncoder
    )

    # Save to file
    with open("mac_stats_dashboard.json", "w") as f:
        f.write(dashboard_json)

    print("Dashboard JSON saved to mac_stats_dashboard.json")


if __name__ == "__main__":
    main()
