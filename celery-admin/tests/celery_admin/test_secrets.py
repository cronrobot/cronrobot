import pytest
from celery_admin import secrets


@pytest.fixture(autouse=True)
def run_around_tests(monkeypatch):
    yield


def test_secrets_get_auth0_access_token():
    token = secrets.get_auth0_access_token()

    assert len(token) > 0
