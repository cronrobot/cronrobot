import logging
import json

from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.forms.models import model_to_dict
from ..models import ResourcesModel
from ..secrets import encrypt


# Get an instance of a logger
logger = logging.getLogger(__name__)


@api_view(["POST"])
def create(request):
    body = request.data

    r = ResourcesModel.objects.create(
        name=body.get("name"),
        reference_id=body.get("reference_id"),
        data=body.get("data"),
    )

    return Response(model_to_dict(r))


@api_view(["GET", "PATCH", "DELETE"])
def manage(request, id):
    if request.method == "GET":
        return Response(model_to_dict(ResourcesModel.objects.filter(id=id).first()))
    elif request.method == "DELETE":
        ResourcesModel.objects.filter(id=id).delete()

        return Response({})
    elif request.method == "PATCH":
        body = request.data

        obj = ResourcesModel.objects.get(id=id)

        if body.get("name"):
            obj.name = body.get("name")

        if body.get("reference_id"):
            obj.reference_id = body.get("reference_id")

        if body.get("data"):
            obj.data = body.get("data")

        obj.save()

        return Response(model_to_dict(obj))
