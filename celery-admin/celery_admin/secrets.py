
import os
from cryptography.fernet import Fernet

secret_type = os.environ.get("SECRET_TYPE", "FERNET")

SUPPORTED_SECRET_TYPES = ["FERNET"]

if secret_type not in SUPPORTED_SECRET_TYPES:
    raise Exception(f"Invalid secret type {secret_type}")

def get_secret_key():
    return os.environ.get("FERNET_SECRET_KEY", "")

def decrypt(encrypted_msg):
    return decrypt_fernet(encrypted_msg)

def decrypt_fernet(encrypted_msg):
    f = Fernet(get_secret_key())
    
    return f.decrypt(encrypted_msg.encode()).decode("utf-8")

