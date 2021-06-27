import os

import requests
import json
import time
from functools import lru_cache
from dotenv import dotenv_values
from celery.utils.log import get_task_logger

dotenv_values = dotenv_values(os.environ["DOTENV_PATH"])

auth0_tenant_url = dotenv_values["RESOURCE_SECRETS_AUTH0_TENANT_URL"]
auth0_client_id = dotenv_values["RESOURCE_SECRETS_AUTH0_CLIENT_ID"]
auth0_client_secret = dotenv_values["RESOURCE_SECRETS_AUTH0_CLIENT_SECRET"]
auth0_audience = dotenv_values["RESOURCE_SECRETS_AUTH0_AUDIENCE"]
resource_secret_base_url = dotenv_values["RESOURCE_SECRETS_API_BASE_URL"]

logger = get_task_logger(__name__)


def get_auth0_access_token(ttl_hash=None):
    token_url = f"{auth0_tenant_url}/oauth/token"
    logger.info(f"Retrieving an auth0 token, {token_url}")

    data = {
        "client_id": auth0_client_id,
        "client_secret": auth0_client_secret,
        "audience": auth0_audience,
        "grant_type": "client_credentials",
    }

    result = requests.post(token_url, timeout=60, json=data)

    if result.status_code != 200:
        raise Exception(f"{result.text}, status code = {result.status_code}")

    parsed_result = json.loads(result.text)

    return parsed_result.get("access_token")


def get_ttl_hash(seconds=80000):
    """Return the same value withing `seconds` time period"""
    return round(time.time() / seconds)


def decrypt(resource_id):
    access_token = get_auth0_access_token(ttl_hash=get_ttl_hash())

    resource_url = f"{resource_secret_base_url}/{resource_id}"
    headers = {"Authorization": f"Bearer {access_token}"}
    decrypted = requests.get(resource_url, timeout=60, headers=headers)

    if decrypted.status_code != 200:
        raise Exception(f"Unable to retrieve resource")

    return decrypted.json()
