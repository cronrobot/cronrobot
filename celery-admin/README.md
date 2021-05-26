
python manage.py runserver

celery -A celery_admin beat -l INFO

celery -A celery_admin worker -l INFO