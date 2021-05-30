import pytest
import json
from celery_admin import celery, secrets

test_fernet_key = "BFrJh-fIWvhwokDhsIIhjMuHxcgDXjyNZY_JIQZD78M="


@pytest.fixture(autouse=True)
def run_around_tests(monkeypatch):
    monkeypatch.setenv("FERNET_SECRET_KEY", test_fernet_key)
    yield


def test_celery_http_no_params():
    body = {"name": "testtask"}
    encr_params = secrets.encrypt(json.dumps(body))

    result = celery.http(encrypted_params=encr_params)

    assert "No params available" in result
