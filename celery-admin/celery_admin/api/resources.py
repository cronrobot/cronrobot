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
    print(f"data is {body.get('data')}")

    return Response(model_to_dict(r))


@api_view(["GET", "DELETE"])
def manage(request, id):
    if request.method == "GET":
        print(f"manage.. get")
        return Response(model_to_dict(ResourcesModel.objects.filter(id=id).first()))
    if request.method == "DELETE":
        print(f"manage.. delete")
        ResourcesModel.objects.filter(id=id).delete()

        return Response({})
