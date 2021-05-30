FROM python:3.8

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

RUN echo '' > /boot.sh

COPY . .

# run migrations
RUN echo 'python manage.py migrate' >> /boot.sh

# start the server
CMD sh /boot.sh && python manage.py runserver 0.0.0.0:8000