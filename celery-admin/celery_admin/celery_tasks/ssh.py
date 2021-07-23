import io
import paramiko
import time
from celery.utils.log import get_task_logger

logger = get_task_logger(__name__)

connections = {}

def ssh_cmd(
    host=None, port=None, username=None, private_key=None, cmd=None, timeout=None
):
    connection_id = f"{username}@{host}:{port}"
    file_pk = io.StringIO(private_key)
    loaded_private_key = paramiko.RSAKey.from_private_key(file_pk)

    connection = connections.get(connection_id)

    if not connection or not ssh_conn_active(connection["client"]):
        ssh_client = paramiko.SSHClient()
        connections[connection_id] = { "touched_at": time.time(), "client": ssh_client }
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        ssh_client.connect(
            hostname=host, port=port, username=username, pkey=loaded_private_key
        )
    else:
        logger.debug(f"skipping connection for connection {connection_id}")

    ssh_client = connections[connection_id]["client"]

    channel = ssh_client.get_transport().open_session()

    channel.exec_command(cmd)
    ssh_wait_until_ready(channel, timeout)

    exit_code = channel.recv_exit_status()
    output = channel.recv(1000000000)
    channel.close()
    connection["touched_at"] = time.time()

    print(f"all connections -> {connections}")

    #ssh_client.close()

    return {"exit_code": exit_code, "output": output}

def ssh_conn_active(ssh_client):
    if ssh_client.get_transport() is not None:
        return ssh_client.get_transport().is_active()

    return False

def ssh_wait_until_ready(channel, timeout):
    start = time.time()

    while time.time() < start + timeout:
        if channel.exit_status_ready():
            break

        time.sleep(0.5)
    else:
        raise TimeoutError(f"Command timed out")


def task(**kwargs):
    default_timeout = 30  # seconds
    default_expected_exit_code = 0

    body = kwargs.get("body")
    params = body.get("params")

    username = params.get("username")
    host = params.get("host")
    port = params.get("port")
    command = params.get("command")
    private_key = params.get("private_key")

    timeout = params.get("timeout") or default_timeout
    expected_exit_code = params.get("expected_exit_code") or default_expected_exit_code

    try:
        result = ssh_cmd(
            host=host,
            port=port,
            username=username,
            private_key=private_key,
            cmd=command,
            timeout=timeout,
        )

        exit_code = result.get("exit_code")

        if exit_code == expected_exit_code:
            return {"exit_code": exit_code}
        else:
            raise Exception({"exit_code": exit_code})
    except Exception as e:

        raise e

    return {}
