from celery_admin.celery_tasks import ssh


def test_celery_tasks_ssh_ssh_connection_key_happy_path():
    result = ssh.ssh_connection_key(
        host="localhost", port=22, username="ubuntu", private_key="--"
    )

    assert result == "1af262d3a1425a8c14a51f0932bc32e6f1e82a22af0f4556a1469454435db9a8"

    result = ssh.ssh_connection_key(
        host="localhost", port=22, username="ubuntu", private_key="---"
    )

    assert result == "a44147b6c310b45c8d4ac382915c3a55bcb26815b2dc55913dfc0ccd28168ab2"
