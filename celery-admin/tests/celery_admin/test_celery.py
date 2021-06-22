import pytest
import json
import copy
from celery_admin import celery


@pytest.fixture(autouse=True)
def run_around_tests(monkeypatch):
    def dummy_write(content):
        pass

    celery.write_task_result_file = dummy_write

    yield


def mock_oauth_resources(requests_mock):

    requests_mock.post(
        "https://dev-4eegkib6.us.auth0.com/oauth/token",
        json={"access_token": "at"},
        headers={"content-type": "json"},
        status_code=200,
    )


def mock_resources_api(requests_mock, id, body):

    requests_mock.get(
        f"http://localhost:3030/api/resources/{id}",
        json=body,
        status_code=200,
        headers={"content-type": "json"},
    )


# SOCKET PING


def test_celery_socket_ping_not_listening(requests_mock):
    mock_oauth_resources(requests_mock)

    params = {
        "host": "127.0.0.1",
        "port": 55555,
        "socket_type": "TCP",
    }
    mock_resources_api(requests_mock, 1234, {"params": params})

    body = {"name": "testtask", "params": {"resource_id": "1234"}}

    result = celery.socket_ping(body=body)

    assert result["level"] == "error"
    assert result["status"] == "error"
    assert result["status_int"] == 0
    assert "down" in result["result"]["error"]


## HTTP


def test_celery_http_no_params():
    body = {"name": "testtask"}

    result = celery.http(body=body)

    assert "No params" in result["result"]["error"]
    assert result["status"] == "error"


def test_celery_http_happy_path(requests_mock):
    requests_mock.get("http://myrequest.com/test", text='{"this": "is"}')

    mock_oauth_resources(requests_mock)
    mock_resources_api(
        requests_mock, 1234, {"params": {"url": "http://myrequest.com/test"}}
    )

    body = {"name": "testtask", "params": {"resource_id": 1234, "scheduler_id": 22}}
    orig_body = copy.deepcopy(body)

    result = celery.http(body=body)

    assert result["level"] == "info"
    assert result["status"] == "success"
    assert result["status_int"] == 100
    assert result["body"] == orig_body
    assert result["result"]["content"] == '{"this": "is"}'
    assert result["result"]["status"] == "success"
    assert result["result"]["status_code"] == 200
    assert result["result"]["duration"] > 0


def test_celery_http_exception_on_call(requests_mock):
    params = {
        "url": "http://myrequest.com/testexception",
        "timeout": 3,
        "scheduler_id": 22,
    }

    result = celery.http(body={"params": params})

    assert result["level"], "error"
    assert result["status"], "error"
    assert result["body"] == {"params": params}
    assert "No mock address" in result["result"]["error"]
    assert result["result"]["duration"] > 0
