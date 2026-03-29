#!/usr/bin/env bash
# ─────────────────────────────────────────────────────
# devops-lab — One-command local setup
# Usage: ./scripts/setup.sh
# ─────────────────────────────────────────────────────
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()  { echo -e "${GREEN}[setup]${NC} $*"; }
warn() { echo -e "${YELLOW}[warn]${NC}  $*"; }
err()  { echo -e "${RED}[error]${NC} $*" >&2; exit 1; }

# ── Prerequisites check ───────────────────────────────
log "Checking prerequisites..."

command -v docker  &>/dev/null || err "Docker not found. Install from https://docs.docker.com/get-docker/"
command -v git     &>/dev/null || err "Git not found."

DOCKER_VERSION=$(docker --version | grep -oP '\d+\.\d+')
log "Docker ${DOCKER_VERSION} ✓"

# Check Docker daemon is running
docker info &>/dev/null || err "Docker daemon is not running. Start Docker Desktop or 'sudo systemctl start docker'"

log "All prerequisites met ✓"

# ── Create .env if missing ────────────────────────────
if [ ! -f .env ]; then
  log "Creating .env from template..."
  cat > .env << 'EOF'
APP_VERSION=1.0.0
FLASK_ENV=production
EOF
  warn ".env created — review before production use"
fi

# ── Build and start ───────────────────────────────────
log "Building and starting stack..."
docker compose up -d --build

# ── Wait for services ─────────────────────────────────
log "Waiting for services to be healthy..."
sleep 5

MAX_RETRIES=10
for i in $(seq 1 $MAX_RETRIES); do
  if curl -sf http://localhost/health &>/dev/null; then
    log "App is healthy ✓"
    break
  fi
  if [ "$i" -eq "$MAX_RETRIES" ]; then
    err "App did not become healthy. Check logs: docker compose logs app"
  fi
  sleep 3
done

# ── Summary ───────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  devops-lab is running!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  🌐 App:        http://localhost"
echo "  📊 Prometheus: http://localhost:9090"
echo "  📈 Grafana:    http://localhost:3000  (admin / admin)"
echo ""
echo "  Commands: make help"
echo ""
