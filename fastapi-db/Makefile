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

docker-up: ## Build and start the Docker containers
	source myapp.env && docker-compose --env-file myapp.env up -d --build

test-curl: ## Run the API tests using the curl script
	source myapp.test.env && curl -X GET http://127.0.0.1:${MYAPP_PORT}/items

test:  ## Run tests on test database
	source myapp.test.env && uv run pytest -s -v

docker-down: ## Stop the Docker containers
	docker-compose stop
