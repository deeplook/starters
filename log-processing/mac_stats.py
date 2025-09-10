#!/usr/bin/env python3
import json
import subprocess
import time
from datetime import datetime, timezone


LOG_FILE = "/tmp/mac_stats.log"


def get_cpu_usage():
    """Gets CPU usage percentage."""
    try:
        top_output = subprocess.check_output(["top", "-l", "1"], text=True)
        for line in top_output.splitlines():
            if "CPU usage" in line:
                # Example line: "CPU usage: 6.19% user, 23.61% sys, 70.18% idle"
                # The shell script gets the user percentage, which is the 3rd field.
                usage_str = line.split()[2].replace("%", "")
                return float(usage_str)
    except (subprocess.CalledProcessError, ValueError, IndexError) as e:
        print(f"Error getting CPU usage: {e}")
    return None


def get_memory_pressure():
    """Gets system-wide free memory percentage."""
    try:
        pressure_output = subprocess.check_output(["memory_pressure"], text=True)
        for line in pressure_output.splitlines():
            if "System-wide memory free percentage" in line:
                # Example line: "System-wide memory free percentage: 37%"
                pressure_str = line.split()[4].replace("%", "")
                return int(pressure_str)
    except (subprocess.CalledProcessError, ValueError, IndexError) as e:
        print(f"Error getting free memory: {e}")
    return None


def get_battery_info():
    """Gets battery percentage and power source."""
    try:
        battery_output = subprocess.check_output(["pmset", "-g", "batt"], text=True)
        if "No batteries found" in battery_output:
            return None, "No Battery"

        percentage = None
        source = "Unknown"

        # Extract percentage
        for line in battery_output.splitlines():
            if "%" in line:
                try:
                    # Example line: "-InternalBattery-0 (id=12345)    100%; charged; 0:00 remaining present: true"
                    percentage_str = line.split(";")[0].split("\t")[1].replace("%", "")
                    percentage = int(percentage_str)
                    break
                except (ValueError, IndexError):
                    continue  # Continue if parsing this line fails

        # Determine power source
        if "'AC Power'" in battery_output:
            source = "AC Power"
        elif "'Battery Power'" in battery_output:
            source = "Battery Power"

        return percentage, source

    except (subprocess.CalledProcessError, FileNotFoundError) as e:
        print(f"Error getting battery info: {e}")
        # This can happen on systems without pmset or a battery
        return None, "No Battery"


def main():
    """Main loop to log mac stats."""
    print(f"Starting MacBook stats logger. Outputting to {LOG_FILE}")
    print("Press [CTRL+C] to stop.")

    try:
        # Ensure the log file exists, similar to `touch`
        with open(LOG_FILE, "a") as f:
            pass

        while True:
            timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
            cpu_usage = get_cpu_usage()
            memory_pressure = get_memory_pressure()
            battery_percentage, power_source = get_battery_info()

            stats = {
                "timestamp": timestamp,
                "component": "mac_stats",
                "cpu_usage_percent": cpu_usage,
                "memory_free_percent": memory_pressure,
                "battery_percentage": battery_percentage,
                "power_source": power_source,
            }

            json_output = json.dumps(stats)

            with open(LOG_FILE, "a") as f:
                f.write(json_output + "\n")

            time.sleep(10)

    except KeyboardInterrupt:
        print("\nStopping logger.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


if __name__ == "__main__":
    main()
