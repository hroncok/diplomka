Python REST API framework
=========================

```{caption="{#code:praf}Příklad použití z dokumentace PRAF \autocite{praf}" .python}
from rest_api_framework import models
from rest_api_framework.datastore import SQLiteDataStore
from rest_api_framework.views import JsonResponse
from rest_api_framework.controllers import Controller
from rest_api_framework.datastore.validators import UniqueTogether
from rest_api_framework.pagination import Pagination


class UserModel(models.Model):
    """Define how to handle and validate your data."""
    fields = [models.StringField(name="first_name", required=True),
              models.StringField(name="last_name", required=True),
              models.PkField(name="id", required=True)
              ]


def remove_id(response, obj):
    """Do not show the id in the response."""
    obj.pop(response.model.pk_field.name)
    return obj


class UserEndPoint(Controller):
    ressource = {
        "ressource_name": "users",
        "ressource": {"name": "adress_book.db", "table": "users"},
        "model": UserModel,
        "datastore": SQLiteDataStore,
        "options": {"validators": [UniqueTogether("first_name",
                                                  "last_name")]}
        }

    controller = {
        "list_verbs": ["GET", "POST"],
        "unique_verbs": ["GET", "PUT", "DELETE"],
        "options": {"pagination": Pagination(20)}
        }

    view = {"response_class": JsonResponse,
            "options": {"formaters": ["add_ressource_uri",
                                      remove_id]}}


if __name__ == '__main__':
    from werkzeug.serving import run_simple
    from rest_api_framework.controllers import WSGIDispatcher
    app = WSGIDispatcher([UserEndPoint])
    run_simple('127.0.0.1', 5000, app, use_debugger=True,
               use_reloader=True)
```