import logging
import json

from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.forms.models import model_to_dict
from django_celery_beat.models import PeriodicTask, PeriodicTasks, CrontabSchedule


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

    if p:
        return Response(model_to_dict(p))
    else:
        return Response(None, status=404)


@api_view(["POST"])
def create(request):
    body = request.data

    schedule_s = body.get("schedule")
    name = body.get("name")
    task = body.get("task")
    kwargs = json.dumps(
        {
            "body": {
                "params": {
                    "project_id": body.get("project_id"),
                    "resource_id": body.get("resource_id"),
                    "scheduler_id": body.get("scheduler_id"),
                }
            }
        }
    )

    if not schedule_s:
        return Response({"error": "Missing schedule"}, status=400)

    parts_schedule = schedule_s.split(" ")

    if len(parts_schedule) != 5:
        return Response({"error": "Invalid schedule format"}, status=400)

    crontab, _ = CrontabSchedule.objects.get_or_create(
        minute=parts_schedule[0],
        hour=parts_schedule[1],
        day_of_week=parts_schedule[2],
        day_of_month=parts_schedule[3],
        month_of_year=parts_schedule[4],
    )

    # upsert
    p_task = PeriodicTask.objects.filter(name=name).first()

    if p_task:
        p_task.task = task
        p_task.crontab = crontab
        p_task.kwargs = kwargs
        p_task.save()
    else:
        p_task = PeriodicTask.objects.create(
            crontab=crontab,
            name=name,
            task=task,
            kwargs=kwargs,
        )

    return Response(model_to_dict(p_task))


@api_view(["DELETE"])
def manage(request, id):
    PeriodicTask.objects.filter(name=id).delete()

    return Response({})


@api_view(["POST"])
def enable(request, id):
    task = PeriodicTask.objects.filter(id=id).first()

    task.enabled = True
    task.save()

    return Response({})


@api_view(["POST"])
def disable(request, id):
    task = PeriodicTask.objects.filter(id=id).first()

    task.enabled = False
    task.save()

    return Response({})
