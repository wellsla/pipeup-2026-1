# ===========================================
# PipeUp 2026 — Project Commands
# ===========================================
# Usage: make [command]
# ===========================================

.PHONY: help up down restart build logs \
        api-shell api-install api-migrate api-seed api-fresh api-key api-tinker api-test api-routes \
        front-shell front-install front-dev front-build front-lint front-storybook \
        db-shell telescope prepare clean

# Default
help: ## Show this help
	@echo ""
	@echo "  PipeUp 2026 — Available Commands"
	@echo "  ================================="
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ─── Docker ───────────────────────────────────────────

up: ## Start all containers
	docker compose up -d

down: ## Stop all containers
	docker compose down

restart: ## Restart all containers
	docker compose down && docker compose up -d

build: ## Build/rebuild all containers
	docker compose up -d --build

logs: ## Tail logs from all containers
	docker compose logs -f

logs-api: ## Tail logs from API container
	docker compose logs -f app nginx

logs-front: ## Tail logs from frontend container
	docker compose logs -f frontend

status: ## Show container status
	docker compose ps

clean: ## Stop containers and remove volumes (⚠️ destroys database)
	docker compose down -v

# ─── API (Laravel) ────────────────────────────────────

api-shell: ## Open a shell inside the API container
	docker compose exec app sh

api-install: ## Install API composer dependencies
	docker compose exec app composer install

api-migrate: ## Run database migrations
	docker compose exec app php artisan migrate

api-seed: ## Run database seeders
	docker compose exec app php artisan db:seed

api-fresh: ## Drop all tables and re-run migrations + seeders
	docker compose exec app php artisan migrate:fresh --seed

api-key: ## Generate Laravel application key
	docker compose exec app php artisan key:generate

api-tinker: ## Open Laravel Tinker REPL
	docker compose exec app php artisan tinker

api-test: ## Run API tests
	docker compose exec app php artisan test

api-routes: ## List all API routes
	docker compose exec app php artisan route:list

api-cache-clear: ## Clear all Laravel caches
	docker compose exec app php artisan optimize:clear

telescope: ## Open Telescope URL
	@echo "→ http://localhost:$${API_PORT:-8080}/telescope"

# ─── Frontend (Vue) ──────────────────────────────────

front-shell: ## Open a shell inside the frontend container
	docker compose exec frontend sh

front-install: ## Install frontend dependencies with Yarn
	docker compose exec frontend yarn install

front-dev: ## Start Vite dev server
	docker compose exec frontend yarn dev --host 0.0.0.0

front-build: ## Build frontend for production
	docker compose exec frontend yarn build

front-lint: ## Run ESLint
	docker compose exec frontend yarn lint

front-format: ## Run Prettier
	docker compose exec frontend yarn format

front-storybook: ## Start Storybook
	docker compose exec frontend yarn storybook

front-type-check: ## Run TypeScript type check
	docker compose exec frontend yarn type-check

# ─── Database ─────────────────────────────────────────

db-shell: ## Open MySQL shell
	docker compose exec mysql mysql -u$${DB_USERNAME:-pipeup} -p$${DB_PASSWORD:-secret} $${DB_DATABASE:-pipeup}

# ─── Project Setup ────────────────────────────────────

prepare: ## Full project setup (build + install + migrate + seed)
	@echo "🚀 Building containers..."
	docker compose up -d --build
	@echo "📦 Installing API dependencies..."
	docker compose exec app composer install
	@echo "🔑 Generating app key..."
	docker compose exec app php artisan key:generate
	@echo "🗃️  Running migrations..."
	docker compose exec app php artisan migrate
	@echo "🌱 Running seeders..."
	docker compose exec app php artisan db:seed
	@echo "📦 Installing frontend dependencies..."
	docker compose exec frontend yarn install
	@echo "✅ Project ready! API: http://localhost:$${API_PORT:-8080} | Frontend: http://localhost:$${FRONTEND_PORT:-5173}"
