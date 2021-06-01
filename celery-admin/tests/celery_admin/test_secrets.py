import pytest
from celery_admin import secrets

test_fernet_key = "BFrJh-fIWvhwokDhsIIhjMuHxcgDXjyNZY_JIQZD78M="


@pytest.fixture(autouse=True)
def run_around_tests(monkeypatch):
    monkeypatch.setenv("FERNET_SECRET_KEY", test_fernet_key)
    yield


def test_secrets_get_secret_key():
    assert secrets.get_secret_key() == test_fernet_key
