# README

## Running in dev

Make sure to have a .env file, if it is missing:

        touch .env

Boot the rails application in development environment:

        docker-compose up

## Secret keys

        rails credentials:edit --environment=production

## Running tests

With a .env file with some configs, run:

        export $(cat .env | xargs) && rails test
