import os

from celery import Celery
from .secrets import decrypt

os.environ.setdefault('DJANGO_SETTINGS_MODULE',
                      'celery_admin.settings')

app = Celery('celery_admin')

app.config_from_object('django.conf:settings', namespace='CELERY')
app.autodiscover_tasks()

@app.task(bind=True)
def ssh(self, **kwargs):
    print(f"SSH ing, kwargs = {kwargs}")

@app.task(bind=True)
def debug_task(self):
    # encrypted_resource = {
    # 
    # }
    dec = decrypt("gAAAAABgruSZwSlU_kge70MFTP474_riUujZYwWNi7Xcm-IFHcganatg7TxQ8b_WiRbQqp0XFeR0XreNjKLNQksqRGSoyWY50A==")
    print(f"decrypted -> {dec}")
    print(f'Request: {self.request!r}')


@app.task(bind=True)
def hello_world(self):
    print('Hello world ;)!')