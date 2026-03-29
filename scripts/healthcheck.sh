#!/usr/bin/env bash
# ─────────────────────────────────────────────────────
# devops-lab — Stack health verification
# Usage: ./scripts/healthcheck.sh
# ─────────────────────────────────────────────────────
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0; FAIL=0

check() {
  local name="$1" url="$2" pattern="${3:-}"
  local response
  if response=$(curl -sf --max-time 5 "$url" 2>/dev/null); then
    if [[ -z "$pattern" ]] || echo "$response" | grep -q "$pattern"; then
      echo -e "  ${GREEN}✓${NC} $name"
      ((PASS++))
    else
      echo -e "  ${RED}✗${NC} $name — unexpected response"
      ((FAIL++))
    fi
  else
    echo -e "  ${RED}✗${NC} $name — unreachable"
    ((FAIL++))
  fi
}

echo ""
echo -e "${YELLOW}devops-lab health check${NC}"
echo "────────────────────────────"
check "App /health"        "http://localhost/health"       "healthy"
check "App /metrics"       "http://localhost:5000/metrics" "app_request"
check "Prometheus"         "http://localhost:9090/-/ready"
check "Grafana"            "http://localhost:3000/api/health"
echo "────────────────────────────"
echo -e "  Passed: ${GREEN}${PASS}${NC}  Failed: ${RED}${FAIL}${NC}"
echo ""

[ "$FAIL" -eq 0 ] || exit 1
