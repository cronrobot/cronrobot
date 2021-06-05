import requests


def task(**kwargs):
    default_http_timeout = 30  # seconds
    body = kwargs.get("body")
    params = body.get("params")

    url = params.get("url")
    timeout = params.get("timeout") or default_http_timeout

    result = requests.get(url, timeout=timeout)

    return {"status_code": result.status_code, "content": result.text}
