.PHONY: up down dev logs build health clean ps shell

# ── Colours ──────────────────────────────────────────
GREEN  := \033[0;32m
YELLOW := \033[0;33m
BLUE   := \033[0;34m
RESET  := \033[0m

help: ## Show this help
	@echo ""
	@echo "$(BLUE)devops-lab$(RESET) — available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-12s$(RESET) %s\n", $$1, $$2}'
	@echo ""

up: ## Start full stack (detached)
	@echo "$(GREEN)▶ Starting devops-lab stack...$(RESET)"
	docker compose up -d --build
	@echo "$(GREEN)✓ Stack running:$(RESET)"
	@echo "  App:        http://localhost"
	@echo "  Prometheus: http://localhost:9090"
	@echo "  Grafana:    http://localhost:3000  (admin/admin)"

down: ## Stop all containers
	@echo "$(YELLOW)▶ Stopping stack...$(RESET)"
	docker compose down

dev: ## Start in development mode (hot reload)
	@echo "$(GREEN)▶ Starting in dev mode...$(RESET)"
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build

logs: ## Tail all logs
	docker compose logs -f

build: ## Rebuild images
	docker compose build --no-cache

health: ## Run health checks
	@echo "$(BLUE)▶ Checking services...$(RESET)"
	@curl -sf http://localhost/health       && echo "$(GREEN)✓ App$(RESET)"    || echo "\033[0;31m✗ App$(RESET)"
	@curl -sf http://localhost:9090/-/ready && echo "$(GREEN)✓ Prometheus$(RESET)" || echo "\033[0;31m✗ Prometheus$(RESET)"
	@curl -sf http://localhost:3000/api/health | grep -q '"database":{"message":"ok"' \
		&& echo "$(GREEN)✓ Grafana$(RESET)" || echo "\033[0;31m✗ Grafana$(RESET)"

ps: ## Show running containers
	docker compose ps

shell: ## Open shell in app container
	docker compose exec app /bin/sh

clean: ## Remove containers, images and volumes
	@echo "$(YELLOW)▶ Cleaning up...$(RESET)"
	docker compose down -v --rmi local
	@echo "$(GREEN)✓ Done$(RESET)"
