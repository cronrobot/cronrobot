import os

import requests
import json
import time
from functools import lru_cache
from dotenv import dotenv_values
from celery.utils.log import get_task_logger

dotenv_values = dotenv_values(os.environ["DOTENV_PATH"])

resource_secret_base_url = dotenv_values["RESOURCE_SECRETS_API_BASE_URL"]
api_client_id = dotenv_values["RESOURCE_SECRETS_API_CLIENT_ID"]
api_client_secret = dotenv_values["RESOURCE_SECRETS_API_CLIENT_SECRET"]

logger = get_task_logger(__name__)


def get_ttl_hash(seconds=80000):
    """Return the same value withing `seconds` time period"""
    return round(time.time() / seconds)


def decrypt(resource_id):
    access_token = get_auth0_access_token(ttl_hash=get_ttl_hash())

    resource_url = f"{resource_secret_base_url}/{resource_id}"
    headers = {
        "x-auth-client-id": api_client_id,
        "x-auth-client-secret": api_client_secret,
    }

    decrypted = requests.get(resource_url, timeout=60, headers=headers)

    if decrypted.status_code != 200:
        raise Exception(f"Unable to retrieve resource")

    return decrypted.json()
