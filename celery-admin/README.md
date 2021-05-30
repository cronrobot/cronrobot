
python manage.py runserver

FERNET_SECRET_KEY=$(cat celery_admin/key.txt) celery -A celery_admin beat -l INFO

FERNET_SECRET_KEY=$(cat celery_admin/key.txt) celery -A celery_admin worker -l INFO