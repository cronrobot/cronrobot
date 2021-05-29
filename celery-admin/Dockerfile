FROM python:3.8

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

# run migrations
RUN echo 'python manage.py migrate' >> /boot.sh

# start the server
CMD python manage.py runserver 0.0.0.0:8000