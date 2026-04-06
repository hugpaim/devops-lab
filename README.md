# 🔧 devops-lab

> A full DevOps stack demonstrating infrastructure patterns — containerised app, CI/CD pipeline, infrastructure as code, and monitoring.

![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat-square&logo=github-actions&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat-square&logo=terraform&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat-square&logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat-square&logo=grafana&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black)
![CI](https://github.com/hugpaim/devops-lab/actions/workflows/ci.yml/badge.svg)

---

## 📐 Architecture

```
┌─────────────────────────────────────────────────────┐
│             GitHub Actions CI/CD                    │
│   push → lint → test → build → push image → deploy  │
└──────────────────────┬──────────────────────────────┘
                       │
         ┌─────────────▼─────────────┐
         │       Docker Compose      │
         │  ┌────────┐  ┌─────────┐  │
         │  │  App   │  │  Nginx  │  │
         │  │ :5000  │  │  :80    │  │
         │  └────────┘  └─────────┘  │
         │  ┌──────────────────────┐ │
         │  │  Prometheus :9090    │ │
         │  │  Grafana    :3000    │ │
         │  └──────────────────────┘ │
         └───────────────────────────┘
```

## 📁 Project Structure

```
devops-lab/
├── app/
│   ├── app.py              # Flask app with /health and /metrics endpoints
│   ├── requirements.txt
│   └── Dockerfile
├── nginx/
│   └── nginx.conf          # Reverse proxy config
├── monitoring/
│   ├── prometheus.yml      # Scrape config
│   └── grafana/
│       └── dashboard.json  # Pre-built dashboard
├── scripts/
│   ├── setup.sh            # One-command local setup
│   └── healthcheck.sh      # Stack health verification
├── .github/
│   └── workflows/
│       └── ci.yml          # Full CI/CD pipeline
├── docker-compose.yml      # Full stack
├── docker-compose.dev.yml  # Dev override (hot reload)
└── Makefile                # Common commands
```

## 🚀 Quick Start

```bash
# 1. Clone
git clone https://github.com/hugpaim/devops-lab.git
cd devops-lab

# 2. Run full stack
make up

# 3. Check everything is running
make health

# 4. Access services
#    App:        http://localhost
#    Prometheus: http://localhost:9090
#    Grafana:    http://localhost:3000  (admin/admin)
```

## ⚙️ Make Commands

| Command | Description |
|---------|-------------|
| `make up` | Start full stack in background |
| `make down` | Stop and remove containers |
| `make dev` | Start in dev mode with hot reload |
| `make logs` | Tail all container logs |
| `make health` | Run health checks |
| `make build` | Rebuild images |
| `make clean` | Remove containers, images, volumes |

## 🔄 CI/CD Pipeline

The GitHub Actions workflow runs on every push to `main`:

1. **Lint** — flake8 Python linting
2. **Test** — pytest unit tests
3. **Build** — Docker image build
4. **Push** — Push to GitHub Container Registry (ghcr.io)
5. **Deploy** — SSH deploy to remote host (configurable)

## 📊 Monitoring

- **Prometheus** scrapes app metrics every 15s
- **Grafana** pre-loaded with dashboard showing request rate, latency, and error rate
- **Health endpoint** at `/health` returns JSON status

## 🛠️ Tech Stack

| Layer | Tool |
|-------|------|
| App | Python / Flask |
| Container | Docker + Docker Compose |
| Reverse Proxy | Nginx |
| CI/CD | GitHub Actions |
| Monitoring | Prometheus + Grafana |
| IaC | Terraform (see terraform-aws-modules) |

---

> Part of [@hugpaim](https://github.com/hugpaim) DevOps portfolio
