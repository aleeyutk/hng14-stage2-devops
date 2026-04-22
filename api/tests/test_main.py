import pytest
import fakeredis
from fastapi.testclient import TestClient
import api.main as main_module
from api.main import app


@pytest.fixture(autouse=True)
def mock_redis(monkeypatch):
    fake_r = fakeredis.FakeRedis()
    monkeypatch.setattr(main_module, "r", fake_r)
    yield
    fake_r.flushall()


client = TestClient(app)


def test_create_job():
    response = client.post("/jobs")
    assert response.status_code == 200
    data = response.json()
    assert "job_id" in data


def test_get_job_status():
    create_response = client.post("/jobs")
    job_id = create_response.json()["job_id"]
    get_response = client.get(f"/jobs/{job_id}")
    assert get_response.status_code == 200
    data = get_response.json()
    assert data["job_id"] == job_id
    assert data["status"] == "queued"


def test_get_nonexistent_job():
    response = client.get("/jobs/nonexistent-id-123")
    assert response.status_code == 404
    assert response.json() == {"error": "not found"}
