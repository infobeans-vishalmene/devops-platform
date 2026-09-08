from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json()["service"] == "demo-api"


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_orders():
    response = client.get("/api/orders")
    assert response.status_code == 200
    assert len(response.json()["orders"]) == 3


def test_error_endpoint():
    response = client.get("/api/error")
    assert response.status_code == 500