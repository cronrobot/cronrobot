from django.db import models


class ResourcesModel(models.Model):
    name = models.CharField(max_length=200, unique=True)
    last_modified = models.DateTimeField(auto_now=True)
    data = models.TextField()
