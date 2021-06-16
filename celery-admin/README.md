

## Running tests

With a .env file with some configs, run:

        export $(cat .env | xargs) && DOTENV_PATH=.env python -m pytest