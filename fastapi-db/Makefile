.PHONY: help all docker-up test-api test docker-down

# Default to 'help' when no target is given
DEFAULT_GOAL := help
.DEFAULT_GOAL := $(DEFAULT_GOAL)

help:  ## Display this help screen
	@echo "Usage: make [target] ..."
	@echo
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: clean
clean: ## Remove temporary build files.
	@echo "Cleaning up..."
	@find . -type f -name "*~" -delete
	@find . -type f -name "*.py[co]" -delete
	@find . -type f -name ".coverage" -delete
	@find . -type f -name "coverage.xml" -delete
	@find . -type d -name "__pycache__" -delete
	@find . -type d -name ".mypy_cache" -delete
	@find . -type d -name ".pytest_cache" -delete
	@find . -type d -name ".rust_cache" -delete
	@find . -type d -name "*.egg-info" -exec rm -rf {} +
	@rm -rf build dist .pytest_cache .ruff_cache .mypy_cache docs/_build

all: build ## Build the application

docker-up: ## Build and start the Docker container. Requires MYAPP_ENV_PATH to be set.
	@if [ -z "$(MYAPP_ENV_PATH)" ]; then \
		echo "Error: MYAPP_ENV_PATH is not set. Please set it to the path of your environment file."; \
		exit 1; \
	fi
	@if [ ! -f "$(MYAPP_ENV_PATH)" ]; then \
		echo "Error: Environment file not found at $(MYAPP_ENV_PATH)"; \
		exit 1; \
	fi
	docker-compose --env-file $(MYAPP_ENV_PATH) up -d --build

test-curl: ## Run the API tests using the curl script
	bash tests/test_curl.sh

test:  ## Run tests on database
	uv run pytest -s -v

docker-down: ## Stop the Docker containers
	docker-compose down

start-local: ## Start the application locally
	uv run main.py start

stop-local: ## Stop the application locally
	uv run main.py stop
