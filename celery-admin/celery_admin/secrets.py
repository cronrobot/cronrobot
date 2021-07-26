import os

import requests
import json
import time
from functools import lru_cache
from dotenv import dotenv_values
from celery.utils.log import get_task_logger

dotenv_values = dotenv_values(os.environ["DOTENV_PATH"])

secret_base_url = dotenv_values["SECRETS_API_BASE_URL"]
resource_secret_base_url = dotenv_values["RESOURCE_SECRETS_API_BASE_URL"]
api_client_id = dotenv_values["RESOURCE_SECRETS_API_CLIENT_ID"]
api_client_secret = dotenv_values["RESOURCE_SECRETS_API_CLIENT_SECRET"]

logger = get_task_logger(__name__)


def build_headers():
    return {
        "x-auth-client-id": api_client_id,
        "x-auth-client-secret": api_client_secret,
    }


def api_get(url):
    headers = build_headers()

    response = requests.get(url, timeout=60, headers=headers)

    if response.status_code != 200:
        raise Exception(f"Unable to retrieve the request")

    return response.json()


def decrypt(resource_id):
    resource_url = f"{resource_secret_base_url}/{resource_id}"

    return api_get(resource_url)


def retrieve_secret_variables(project_id, type):
    url = f"{secret_base_url}/projects/{project_id}/resources/{type}"

    return api_get(url)
