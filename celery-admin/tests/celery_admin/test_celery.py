import pytest
import json
import time
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
    assert result["result"]["status"] == "success"
    assert result["result"]["status_code"] == 200
    assert result["result"]["duration"] > 0


def test_celery_http_different_status_code(requests_mock):
    requests_mock.get("http://myrequest.com/test", text='{"this": "is"}', status_code=400)

    mock_oauth_resources(requests_mock)
    mock_resources_api(
        requests_mock, 1234, {"params": {"url": "http://myrequest.com/test"}}
    )

    body = {"name": "testtask", "params": {"resource_id": 1234, "scheduler_id": 22}}
    orig_body = copy.deepcopy(body)

    result = celery.http(body=body)

    assert result["level"] == "error"
    assert result["status"] == "error"
    assert result["status_int"] == 0


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


# SSH


def test_celery_ssh_ssh_should_close_connection_happy_path():
    conn = {"touched_at": time.time() - (60 * 90)}

    assert celery.ssh_task.ssh_should_close_connection(conn)


def test_celery_ssh_ssh_should_close_connection_recently_connected():
    conn = {"touched_at": time.time()}

    assert not celery.ssh_task.ssh_should_close_connection(conn)


def test_celery_ssh_private_key_happy_path(requests_mock):
    params = {
        "host": "localhost",
        "port": 22,
        "username": "ubuntu",
        "private_key": "pk",
        "command": "ls",
    }
    mock_resources_api(requests_mock, 1234, {"params": params})

    body = {"name": "testtask", "params": {"resource_id": 1234, "scheduler_id": 22}}
    orig_body = copy.deepcopy(body)

    log_cmds = []

    def my_ssh_cmd(
        host=None, port=None, username=None, private_key=None, cmd=None, timeout=None
    ):
        log_cmds.append(
            {
                "host": host,
                "port": port,
                "username": username,
                "private_key": private_key,
                "cmd": cmd,
            }
        )

        return {"exit_code": 0, "output": "result"}

    celery.ssh_task.ssh_cmd = my_ssh_cmd

    result = celery.ssh(body=body)

    assert result["level"] == "info"
    assert result["status"] == "success"
    assert result["status_int"] == 100
    assert result["body"] == orig_body
    assert result["result"]["exit_code"] == 0


def test_celery_ssh_private_key_cmd_failing(requests_mock):
    params = {
        "host": "localhost",
        "port": 22,
        "username": "ubuntu",
        "private_key": "pk",
        "command": "ls",
    }
    mock_resources_api(requests_mock, 1234, {"params": params})

    body = {"name": "testtask", "params": {"resource_id": 1234, "scheduler_id": 22}}
    orig_body = copy.deepcopy(body)

    log_cmds = []

    def my_ssh_cmd(
        host=None, port=None, username=None, private_key=None, cmd=None, timeout=None
    ):
        log_cmds.append(
            {
                "host": host,
                "port": port,
                "username": username,
                "private_key": private_key,
                "cmd": cmd,
            }
        )

        return {"exit_code": 110, "output": "result"}

    celery.ssh_task.ssh_cmd = my_ssh_cmd

    result = celery.ssh(body=body)

    assert result["level"] == "error"
    assert result["status"] == "error"
    assert result["status_int"] == 0
    assert result["body"] == orig_body
    assert "'exit_code': 110" in result["result"]["error"]


# replace_attribute_secret_variables


def test_celery_replace_attribute_secret_variables_happy_path():
    variables = [{"params": {"name": "vv1", "value": "val"}}]

    result = celery.replace_attribute_secret_variables("hello {{ vv1 }}!", variables)

    assert result == "hello val!"


def test_celery_replace_attribute_secret_variables_without_replacement():
    variables = [{"params": {"name": "vv2", "value": "val"}}]

    result = celery.replace_attribute_secret_variables("hello {{ vv1 }}!", variables)

    assert result == "hello !"


def test_celery_replace_attribute_secret_variables_with_many():
    variables = [
        {"params": {"name": "vv2", "value": "val"}},
        {"params": {"name": "vv3", "value": "TEST"}},
    ]

    result = celery.replace_attribute_secret_variables(
        "hello {{ vv2 }}-{{ vv3 }}!", variables
    )

    assert result == "hello val-TEST!"


# replace_secret_variables


def test_celery_replace_secret_variables_happy_path(requests_mock):
    entity = {"command": "ls -la {{ directory }}", "hello": "any {{ var }} "}

    response_body = [
        {"params": {"name": "directory", "value": "/root/path"}},
        {"params": {"name": "var", "value": "testtest"}},
    ]

    requests_mock.get(
        f"http://localhost:3030/api/projects/1234/resources/ResourceProjectVariable",
        json=response_body,
        status_code=200,
        headers={"content-type": "json"},
    )

    celery.replace_secret_variables(entity, 1234)

    assert entity == {"command": "ls -la /root/path", "hello": "any testtest "}
