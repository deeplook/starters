.PHONY: help all docker-up test-api test docker-down

# Default to 'help' when no target is given
DEFAULT_GOAL := help
.DEFAULT_GOAL := $(DEFAULT_GOAL)

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | awk -f help.awk

all: build ## Build the application

docker-up: ## Build and start the Docker containers
	source myapp.env && docker-compose --env-file myapp.env up -d

test-curl: ## Run the API tests using the curl script
	source myapp.test.env && curl -X GET http://127.0.0.1:${MYAPP_PORT}/items

test:  ## Run tests on test database
	source myapp.test.env && uv run pytest -s -v

docker-down: ## Stop the Docker containers
	docker-compose stop
