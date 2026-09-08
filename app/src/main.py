import time
from fastapi import FastAPI, HTTPException

app = FastAPI(
    title="DevOps Demo API",
    version="1.0.0"
)


@app.get("/")
def root():
    return {
        "service": "demo-api",
        "version": "1.0.0",
        "message": "Hello from DevOps Platform"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.get("/ready")
def ready():
    return {
        "status": "ready"
    }


@app.get("/api/orders")
def get_orders():
    return {
        "orders": [
            {"id": 1, "product": "Laptop"},
            {"id": 2, "product": "Monitor"},
            {"id": 3, "product": "Keyboard"}
        ]
    }


@app.get("/api/error")
def error():
    raise HTTPException(
        status_code=500,
        detail="Intentional application error for incident testing"
    )


@app.get("/api/slow")
def slow():
    time.sleep(5)

    return {
        "message": "This response was intentionally delayed"
    }