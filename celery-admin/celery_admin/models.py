from django.db import models
from .secrets import encrypt, decrypt


class ResourcesModel(models.Model):
    name = models.CharField(max_length=200, unique=True)
    reference_id = models.CharField(max_length=200, default="")
    last_modified = models.DateTimeField(auto_now=True)
    data = models.TextField()

    def save(self, *args, **kwargs):
        self.data = encrypt(self.data)
        return super(ResourcesModel, self).save(*args, **kwargs)
