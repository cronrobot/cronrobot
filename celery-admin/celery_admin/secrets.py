import os

import requests
import json
from dotenv import dotenv_values

dotenv_values = dotenv_values(os.environ["DOTENV_PATH"])

auth0_tenant_url = dotenv_values["RESOURCE_SECRETS_AUTH0_TENANT_URL"]
auth0_client_id = dotenv_values["RESOURCE_SECRETS_AUTH0_CLIENT_ID"]
auth0_client_secret = dotenv_values["RESOURCE_SECRETS_AUTH0_CLIENT_SECRET"]
auth0_audience = dotenv_values["RESOURCE_SECRETS_AUTH0_AUDIENCE"]
resource_secret_base_url = dotenv_values["RESOURCE_SECRETS_API_BASE_URL"]


def get_auth0_access_token():
    token_url = f"{auth0_tenant_url}/oauth/token"

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


def decrypt(resource_id):

    return ""
