# HeyMax Analytics Stack - Local Development

.PHONY: help build up down logs shell test clean

help: ## Show this help message
	@echo "HeyMax Analytics Stack - Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

build: ## Build Docker containers
	docker-compose build --no-cache

up: ## Start the analytics stack
	docker-compose up -d
	@echo "Analytics stack started!"
	@echo "Dagster UI: http://localhost:3000"
	@echo "PostgreSQL: localhost:5432"

down: ## Stop the analytics stack
	docker-compose down

logs: ## View logs from all services
	docker-compose logs -f

logs-web: ## View Dagster webserver logs
	docker-compose logs -f dagster_webserver

logs-daemon: ## View Dagster daemon logs
	docker-compose logs -f dagster_daemon

shell: ## Open shell in Dagster container
	docker-compose exec dagster_webserver bash

shell-db: ## Connect to PostgreSQL database
	docker-compose exec dagster_postgres psql -U dagster_user -d dagster_storage

test: ## Run tests (once implemented)
	docker-compose exec dagster_webserver python -m pytest

clean: ## Clean up Docker resources
	docker-compose down -v
	docker system prune -f

setup: ## Initial setup (copy CSV and build)
	@echo "Setting up HeyMax Analytics Stack..."
	@if [ ! -f ".env" ]; then \
		echo "Creating .env file from template..."; \
		cp .env.example .env; \
		echo "Please edit .env file with your GCP credentials"; \
	fi
	@if [ ! -f "service-account-key.json" ]; then \
		echo "Please place your GCP service account key as 'service-account-key.json'"; \
	fi
	@echo "Copying sample data..."
	@mkdir -p data/
	@echo "Place your CSV files in the data/ directory"
	@echo "Building containers..."
	$(MAKE) build
	@echo "Setup complete! Run 'make up' to start the stack"

dev: ## Start development environment
	$(MAKE) build
	$(MAKE) up
	@echo "Development environment ready!"
	@echo "Open http://localhost:3000 in your browser"

restart: ## Restart services
	$(MAKE) down
	$(MAKE) up

status: ## Show service status
	docker-compose ps