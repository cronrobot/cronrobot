import pytest
from celery_admin import secrets


@pytest.fixture(autouse=True)
def run_around_tests(monkeypatch):
    yield


def test_secrets_decrypt_resource_happy_path(requests_mock):
    requests_mock.get("http://localhost:3030/api/resources/1234", text='{"id": 123}')

    decrypted = secrets.decrypt(1234)

    assert decrypted == {"id": 123}


def test_secrets_decrypt_resource_not_found(requests_mock):

    requests_mock.get(
        "http://localhost:3030/api/resources/1234", text='{"id": 123}', status_code=404
    )

    with pytest.raises(Exception):
        secrets.decrypt(1234)


# retrieve_secret_variables


def test_secrets_decrypt_resource_happy_path(requests_mock):
    requests_mock.get(
        "http://localhost:3030/api/projects/1234/resources/MyType", text='{"id": 123}'
    )

    response = secrets.retrieve_secret_variables(1234, "MyType")

    assert response == {"id": 123}
