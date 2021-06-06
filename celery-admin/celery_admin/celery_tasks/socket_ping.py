import socket


def task(**kwargs):
    body = kwargs.get("body")
    params = body.get("params")

    host = params.get("host")
    port = params.get("port")
    socket_type = params.get("socket_type") or "TCP"

    socket_type_id = socket.SOCK_STREAM if socket_type == "TCP" else socket.SOCK_DGRAM

    socket_def = socket.socket(socket.AF_INET, socket_type_id)

    try:
        result_of_check = socket_def.connect_ex((host, port))

        if result_of_check == 0:
            return {"socket_status": "up"}
        else:
            raise Exception(
                {"socket_status": "down", "socket_status_code": result_of_check}
            )
    except Exception as e:

        raise e
    finally:
        socket_def.close()

    return {}
