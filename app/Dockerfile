#	Stage 1: build dependencies

FROM python:3.12-slim AS builder

WORKDIR /build

# Install dependencies into a local dir (no venv needed in slim image)

COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --prefix=/install --no-cache-dir -r requirements.txt

#	Stage 2: runtime image

FROM python:3.12-slim AS runtime

# Non-root user for security

RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copy installed packages from builder

COPY --from=builder /install /usr/local

# Copy application source

COPY app.py .

# Switch to non-root

USER appuser

# Metadata labels

LABEL maintainer="Hugo Paim <hugocdz@hotmail.com>"
LABEL org.opencontainers.image.source="https://github.com/hugpaim/devops-lab"
LABEL org.opencontainers.image.description="devops-lab Flask app"

EXPOSE 5000

ENV FLASK_ENV=production
ENV PORT=5000

# Health check

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Use gunicorn for production
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "2", "--timeout", "30", "app:app"]
