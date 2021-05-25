
from celery import Celery

app = Celery(
    # XXX The below 'myapp' is the name of this module, for generating
    # task names when executed as __main__.
    'cronflow-scheduler',
    broker='amqp://guest@localhost//',
    # ## add result backend here if needed.
    # backend='rpc'
)

app.conf.timezone = 'UTC'


@app.task
def say(what):
    print(what)
    another_task.delay({"test": f"hello {what}"})

@app.task
def another_task(param):
    print(f"this is another task {param}")


@app.on_after_configure.connect
def setup_periodic_tasks(sender, **kwargs):
    # Calls say('hello') every 10 seconds.

    for i in range(5):
        print(f"add periodic of {i}")
        sender.add_periodic_task(20, say.s(f"world {i}"), name=f"p{i}")

    # See periodic tasks user guide for more examples:
    # http://docs.celeryproject.org/en/latest/userguide/periodic-tasks.html


if __name__ == '__main__':
    app.start()

    print("after start...")