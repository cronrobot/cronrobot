"""celery_admin URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from .api.status import status_ok
from .api import periodic_tasks

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api-auth/", include("rest_framework.urls")),
    path("api/ok", status_ok),
    path("api/periodic-tasks/latest", periodic_tasks.latest),
    path("api/periodic-tasks/find", periodic_tasks.find),
    path("api/periodic-tasks/<id>/", periodic_tasks.manage),
    path("api/periodic-tasks/<id>/enable", periodic_tasks.enable),
    path("api/periodic-tasks/<id>/disable", periodic_tasks.disable),
    path("api/periodic-tasks/", periodic_tasks.create),
]
