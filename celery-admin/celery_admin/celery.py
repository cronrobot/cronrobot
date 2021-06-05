import os
import json

import requests
from functools import wraps

from celery import Celery
from celery.utils.log import get_task_logger

from .celery_tasks import http as http_task
from .celery_tasks import socket_ping as socket_ping_task


from .secrets import decrypt

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "celery_admin.settings")

logger = get_task_logger(__name__)

app = Celery("celery_admin")

app.config_from_object("django.conf:settings", namespace="CELERY")


app.autodiscover_tasks()

STATUS_SUCCESS_LABEL = "success"
STATUS_ERROR_LABEL = "error"

LOG_LEVEL_ERROR = "error"
LOG_LEVEL_INFO = "info"
LOG_LEVEL_DEBUG = "debug"

logger.info(os.environ)
RECORD_TASK_RESULTS_PATH = os.environ.get("TASK_RESULTS_PATH", "out.json")

logger.info(f"Record task results path: {RECORD_TASK_RESULTS_PATH}")


### Global


def handle_task(func):
    @wraps(func)
    def inner(*args, **kwargs):
        body = kwargs.get("body")

        try:
            if not body:
                raise Exception("No body in the task definition")

            params = body.get("params")

            if not params:
                raise Exception("No params in the task definition")

            result = func(*args, **kwargs)
            result["status"] = STATUS_SUCCESS_LABEL

            return record_task_result(LOG_LEVEL_INFO, body, result)

        except Exception as e:
            logger.error(f"HANDLING EX.. e = {e}")
            return record_task_result(
                LOG_LEVEL_ERROR, body, {"error": f"{e}", "status": STATUS_ERROR_LABEL}
            )

    return inner


def write_task_result_file(msg):
    logger.info(f"writing... {RECORD_TASK_RESULTS_PATH}")
    log_file = open(RECORD_TASK_RESULTS_PATH, "a")
    log_file.write(f"{json.dumps(msg)}\n")
    log_file.close()


def record_task_result(level, request_body, result):
    logger.debug(f"record result - request body: {request_body}, result: {result}")

    msg = {
        "level": level,
        "status": result["status"],
        "body": request_body,
        "result": result or {},
    }

    write_task_result_file(msg)

    return msg


### Main tasks


@app.task(bind=True)
@handle_task
def http(self, **kwargs):
    return http_task.task(**kwargs)


@app.task(bind=True)
@handle_task
def socket_ping(self, **kwargs):
    return socket_ping_task.task(**kwargs)


@app.task(bind=True)
def ssh(self, **kwargs):
    # TODO: pass resource id

    params = json.loads(decrypt(kwargs.get("encrypted_params")))


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
