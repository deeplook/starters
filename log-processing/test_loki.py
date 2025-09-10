import os
import time

import pytest
import requests


# --- Test Configuration ---

LOKI_ADDR = os.getenv("LOKI_ADDR", "http://127.0.0.1:3100")
LOKI_API_URL = f"{LOKI_ADDR}/loki/api/v1"
LOKI_TENANT_ID = os.getenv("LOKI_TENANT_ID", "fake")


# --- Fixtures ---


@pytest.fixture(scope="module")
def loki_service():
    """
    A module-scoped fixture that waits for the Loki service to be ready
    before any tests are run.
    """
    max_retries = 12
    for i in range(max_retries):
        try:
            response = requests.get(f"{LOKI_ADDR}/ready", timeout=5)
            if response.status_code == 200 and response.text.strip() == "ready":
                print("Loki is ready.")
                yield requests.Session()  # Provide a session object to tests
                return
        except requests.exceptions.RequestException:
            pass  # Ignore connection errors, etc.
        time.sleep(5)
    pytest.fail(f"Loki not ready at {LOKI_ADDR} after {max_retries * 5} seconds.")


# --- Test Cases ---


def test_loki_log_push_and_query(loki_service):
    """
    Tests the full end-to-end flow of pushing a log and then querying for it.
    """
    # 1. Define a unique log entry to send
    test_labels = {"app": "pytest-test", "source": "test-runner"}
    test_message = f"hello from pytest at {time.time()}"
    timestamp_ns = str(time.time_ns())

    # 2. Push the log entry to Loki
    push_payload = {
        "streams": [
            {
                "stream": test_labels,
                "values": [[timestamp_ns, test_message]],
            }
        ]
    }
    headers = {
        "Content-Type": "application/json",
        "X-Scope-OrgID": LOKI_TENANT_ID,
    }

    print(f"Pushing log: {test_message}")
    push_response = loki_service.post(
        f"{LOKI_API_URL}/push", json=push_payload, headers=headers
    )
    assert push_response.status_code == 204, "Failed to push log entry to Loki"

    # Give Loki a moment to index the new log
    time.sleep(2)

    # 3. Query Loki to verify the log entry was received
    query_params = {
        "query": f'{{app="{test_labels["app"]}", source="{test_labels["source"]}"}}',
        "limit": 10,
        "start": int(timestamp_ns) - 60 * 10**9,  # Query from 1 minute ago
        "direction": "forward",
    }

    print(f"Querying with: {query_params['query']}")
    query_response = loki_service.get(
        f"{LOKI_API_URL}/query_range", params=query_params, headers=headers
    )
    assert query_response.status_code == 200, "Query request to Loki failed"

    # 4. Validate the query result
    results = query_response.json()
    assert results["status"] == "success"
    assert results["data"]["resultType"] == "streams"

    # Ensure we got at least one stream
    assert len(results["data"]["result"]) > 0, "Query returned no streams"

    # Find our specific log message in the returned streams
    found_message = False
    for stream in results["data"]["result"]:
        assert stream["stream"].items() >= test_labels.items()
        for ts, message in stream["values"]:
            if message == test_message:
                found_message = True
                break

    assert found_message, "The specific test message was not found in the query results"
    print("Verification successful: Found log entry.")
