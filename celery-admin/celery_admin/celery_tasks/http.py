import requests


def task(**kwargs):
    default_http_timeout = 30  # seconds
    default_expected_status_code = 200

    body = kwargs.get("body")
    params = body.get("params")

    url = params.get("url")
    timeout = float(params.get("timeout") or default_http_timeout)
    expected_status_code = (
        params.get("expected_status_code") or default_expected_status_code
    )

    try:
        result = requests.get(url, timeout=timeout)

        if result.status_code == expected_status_code:
            return {"status_code": result.status_code}
        else:
            raise Exception({"http_status": "down", "status_code": result.status_code})
    except Exception as e:

        raise e

    return {}
