import os
import json

import requests
import logging

from celery import Celery
from .secrets import decrypt

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "celery_admin.settings")

logger = logging.getLogger(__name__)

app = Celery("celery_admin")

app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()

STATUS_SUCCESS_LABEL = "success"
STATUS_ERROR_LABEL = "error"


def fail_task(msg, body):
    logger.error(msg)

    return msg


def record_task_result(request_body, result):
    logger.debug(f"record result - request body: {request_body}, result: {result}")

    return result


@app.task(bind=True)
def http(self, **kwargs):
    default_http_timeout = 30  # seconds
    body = kwargs.get("body")
    params = body.get("params")

    if not params:
        return fail_task(f"No params available to process the http task", body)

    url = params.get("url")
    timeout = params.get("timeout") or default_http_timeout

    try:
        result = requests.get(url, timeout=timeout)

        return record_task_result(
            body,
            {
                "status_code": result.status_code,
                "content": result.text,
                "status": STATUS_SUCCESS_LABEL,
            },
        )
    except Exception as e:
        return record_task_result(body, {"content": f"{e}", "status": STATUS_ERROR_LABEL})


@app.task(bind=True)
def ssh(self, **kwargs):
    # TODO: pass resource id

    params = json.loads(decrypt(kwargs.get("encrypted_params")))
    print(f"params --> {params}")


@app.task(bind=True)
def debug_task(self):
    # encrypted_resource = {
    #
    # }
    dec = decrypt(
        "gAAAAABgruSZwSlU_kge70MFTP474_riUujZYwWNi7Xcm-IFHcganatg7TxQ8b_WiRbQqp0XFeR0XreNjKLNQksqRGSoyWY50A=="
    )
    print(f"decrypted -> {dec}")
    print(f"Request: {self.request!r}")


@app.task(bind=True)
def hello_world(self):
    print("Hello world ;)!")
