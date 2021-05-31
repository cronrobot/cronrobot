import logging
import json

from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.forms.models import model_to_dict
from django_celery_beat.models import PeriodicTask, PeriodicTasks, CrontabSchedule
from ..secrets import encrypt


# Get an instance of a logger
logger = logging.getLogger(__name__)


@api_view(["GET"])
def latest(request):
    p = PeriodicTask.objects.latest("id")
    return Response(model_to_dict(p))


@api_view(["GET"])
def find(request):
    name = request.GET["name"]
    p = PeriodicTask.objects.filter(name=name).first()

    return Response(model_to_dict(p) if p else None)


@api_view(["POST"])
def create(request):
    body = request.data
    encrypted_body = encrypt(json.dumps(body))

    crontab, _ = CrontabSchedule.objects.get_or_create(
        minute="35", hour="*", day_of_week="*", day_of_month="*", month_of_year="*"
    )

    p_task = PeriodicTask.objects.create(
        crontab=crontab,  # we created this above.
        name=body.get("name"),  # simply describes this periodic task.
        task=body.get("task"),
        kwargs=json.dumps({"encrypted_params": encrypted_body}),
    )

    return Response(model_to_dict(p_task))


@api_view(["DELETE"])
def manage(request, id):
    PeriodicTask.objects.filter(id=id).delete()

    return Response({})
