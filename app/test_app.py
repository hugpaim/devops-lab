import pytest

from app import app as flask_app


@pytest.fixture
def client():
    flask_app.config["TESTING"] = True
    with flask_app.test_client() as client:
        yield client


def test_index_returns_200(client):
    response = client.get("/")
    assert response.status_code == 200


def test_index_returns_json(client):
    response = client.get("/")
    data = response.get_json()
    assert data["service"] == "devops-lab"
    assert data["status"] == "running"
    assert "version" in data
    assert "uptime_seconds" in data


def test_health_returns_200(client):
    response = client.get("/health")
    assert response.status_code == 200


def test_health_returns_healthy(client):
    response = client.get("/health")
    data = response.get_json()
    assert data["status"] == "healthy"
    assert "version" in data
    assert "uptime_seconds" in data


def test_ready_returns_200(client):
    response = client.get("/ready")
    assert response.status_code == 200


def test_ready_returns_json(client):
    response = client.get("/ready")
    data = response.get_json()
    assert data["status"] == "ready"


def test_metrics_returns_200(client):
    response = client.get("/metrics")
    assert response.status_code == 200


def test_metrics_content_type(client):
    response = client.get("/metrics")
    assert b"app_request_count_total" in response.data
