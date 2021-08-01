import os
import json
import time
import copy
import traceback

import requests
from functools import wraps

import chevron
from celery import Celery
from celery.utils.log import get_task_logger

from .celery_tasks import http as http_task
from .celery_tasks import socket_ping as socket_ping_task
from .celery_tasks import ssh as ssh_task

from dotenv import load_dotenv
from .secrets import decrypt, retrieve_secret_variables

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

load_dotenv(os.environ["DOTENV_PATH"])

RECORD_TASK_RESULTS_PATH = os.environ["TASK_RESULTS_PATH"]

logger.info(f"Record task results path: {RECORD_TASK_RESULTS_PATH}")


### Global


def replace_attribute_secret_variables(value, variables):
    replacements = {
        (v.get("params", {}) or {}).get("name"): (v.get("params", {}) or {}).get("value")
        for v in variables
    }

    return chevron.render(value, replacements)


def replace_secret_variables(entity, project_id):
    if not project_id:
        return entity

    variables = retrieve_secret_variables(project_id, "ResourceProjectVariable")

    for k in entity:
        if type(entity[k]) == str:
            entity[k] = replace_attribute_secret_variables(entity[k], variables)

    return entity


def handle_task(func):
    @wraps(func)
    def inner(*args, **kwargs):
        body = kwargs.get("body")
        orig_body = copy.deepcopy(body)
        t_begin = time.time()

        try:
            if not body:
                raise Exception("No body in the task definition")

            # check parameters
            params = body.get("params")

            if not params:
                raise Exception("No params in the task definition")

            # decrypt resource
            resource_id = params.get("resource_id")

            decrypted_resource = decrypt(resource_id)
            resource_params = decrypted_resource.get("params") or {}
            body["params"] = {**resource_params, **params}

            replace_secret_variables(body["params"], params.get("project_id"))

            result = func(*args, **kwargs)
            result["status"] = STATUS_SUCCESS_LABEL

            return record_task_result(LOG_LEVEL_INFO, orig_body, result, t_begin=t_begin)

        except Exception as e:
            logger.error(f"Celery exception, e={e}, exception={traceback.format_exc()}")
            return record_task_result(
                LOG_LEVEL_ERROR,
                orig_body,
                {"error": f"{e}", "status": STATUS_ERROR_LABEL},
                t_begin=t_begin,
            )

    return inner


def write_task_result_file(msg):
    logger.info(f"writing... {RECORD_TASK_RESULTS_PATH}")
    log_file = open(RECORD_TASK_RESULTS_PATH, "a")
    log_file.write(f"{json.dumps(msg)}\n")
    log_file.close()


def record_task_result(level, request_body, result, t_begin=None):
    result = result or {}

    if t_begin:
        result["duration"] = time.time() - t_begin

    logger.debug(f"record result - request body: {request_body}, result: {result}")
    scheduler_id = (request_body.get("params", {}) or {}).get("scheduler_id")
    status_int = 100 if result["status"] == STATUS_SUCCESS_LABEL else 0

    msg = {
        "level": level,
        "scheduler_id": scheduler_id,
        "status": result["status"],
        "status_int": status_int,
        "body": request_body,
        "result": result,
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
@handle_task
def ssh(self, **kwargs):
    return ssh_task.task(**kwargs)


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
