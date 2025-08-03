.PHONY: help

# Default to 'help' when no target is given
DEFAULT_GOAL := help
.DEFAULT_GOAL := $(DEFAULT_GOAL)

help:  ## Display this help screen
	@echo "Usage: make [target] ..."
	@echo
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## Install dependencies and pre-commit hooks.
	uv pip install -e ".[dev]"
	uv run pre-commit install

.PHONY: uninstall
uninstall: ## Uninstall the package from the local virtual environment.
	uv pip uninstall clibro -y

.PHONY: test
test: ## Run the test suite with coverage.
	uv run pytest -s -v --cov

.PHONY: workflow
workflow: ## Run the CI workflow locally using act.
ifndef GITHUB_ACTIONS
	@echo "Running the CI workflow locally with act..."
	@act --container-architecture linux/amd64 -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest
else
	@echo "Skipping 'act' command in GitHub Actions environment."
endif

.PHONY: lint
lint: ## Run the linter and formatter.
	uv run ruff check .
	uv run ruff format .
	uv run mypy src

.PHONY: all
all: install lint test ## Run all checks (install, lint, test).

.PHONY: dist
dist: ## Build the package for distribution.
	uv build

.PHONY: test-dist
test-dist: ## Build and test the distribution wheel.
	@./scripts/test-dist.sh

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

.PHONY: distclean
distclean: clean ## Remove all temporary files and the virtual environment.
	@echo "Cleaning up the virtual environment..."
	@rm -rf .venv

.PHONY: docs
docs: ## Build the documentation.
	cp README.md docs/README.md
	sed -i '' 's|docs/logging.md|logging.md|g' docs/README.md
	sed -i '' 's|docs/configuration.md|configuration.md|g' docs/README.md
	uv run sphinx-build -b html docs docs/_build/html
