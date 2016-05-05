Python REST API framework
=========================

Python REST API framework (zkráceně PRAF) je sada nástrojů postavená na Werkzeugu,
pro snadnou tvorbu RESTful API pomocí MVC architektury [@praf].
Mezi hlavní funkce patří [@praf]:

 * stránkování,
 * autentizace,
 * autorizace,
 * filtry,
 * částečné odpovědi (TODO Partials Response?),
 * řízení chyb,
 * validátory dat,
 * formátovače dat.

PRAF obsahuje několik součástí, které je potřeba využít k tvorbě API [@prafarch]:

 * **datastore** je třída, která nějakým způsobem obstarává data, implicitně může využít buďto SQLite nebo reprezentaci v paměti, pro cokoli jiného musíte implementovat vlastní třídu podle daného rozhraní;
 * **modely** slouží k popsání jednotlivých typ dat v *datastore*;
 * **controller** obsluhuje jeden resource, ve kterém se přistupuje k datům z jednoho modelu v *datastore*;
 * **pohledy** pak definují, jakým způsobem budou data prezentována.

Konkrétní příklad můžete vidět [v ukázce](#code:praf).
Dokumentace obsahuje také komplexnější příklad včetně obsáhlého tutoriálu, jak jej vytvořit [@praftuto].
Kromě tutoriálu je však dokumentace velmi stručná a místy se zdá, že možnosti PRAF příliš nepřesahují rozsah uvedeného příkladu.

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

Python REST API framework je distribuován pod MIT licencí [@MIT].
Za projektem stojí jednotlivec Yohann Gabory, s minimálním přispěním od dalších vývojářů.
PRAF vznikl v roce 2013 a od té doby vyšly pouze čtyři verze. Vývoj není příliš aktivní,
v posledních dvou letech přibilo jen několik jednotek commitů.

Instalace přímo závisí na dvou knihovnách včetně Werkzeugu, celkem pak nepřímo na třech.
Zabírá necelé 3 MiB. Na GitHubu má projekt pouze čtyři hvězdy a z PyPI byl za poslední měsíc stažen jen o něco málo více než dvousetkrát.
Projekt neobsahuje informaci o tom, jestli podporuje Python 3, ale obsahuje minimálně jeden řádek kódu napsaný v nekompatibilní syntaxi,
z čehož soudím, že Python 3 nepodporuje.

HATEOAS
-------

Dokumentace v tutoriálu uvádí postup, jak prolinkovat jednotlivé zdroje mezi sebou [@praflink1][@praflink2].
Framework sám tuto funkci neobsahuje, ale ukazuje příklad formátovače, který je znovupoužitelný v celém projektu
a zajistí, aby všechny cizí klíče byly reprezentovány pomocí odkazu.
Můžete jej vidět [v ukázce](#code:praflink).

```{caption="{#code:praflink}PRAF: Formátovač pro prolinkování dat \autocite{praflink2}" .python}
def format_foreign_key(response, obj):
    from rest_api_framework.models.fields import ForeignKeyField
    for f in response.model.get_fields():
        if isinstance(f, ForeignKeyField):
            obj[f.name] = \
                "/{0}/{1}/".format(f.options["foreign"]["table"],
                                   obj[f.name])
    return obj
```


Přístupová práva
----------------

Tutoriál opět uvádí postup [@prafauth], jak implementovat autentizaci, v tomto konkrétním případě API klíčem předaným pomocí GET parametru zakódovaným v URL.
Pokud chcete, můžete si samozřejmě implementovat způsob vlastní. V případě autorizace nabízí PRAF pouze možnost zpřístupnit daný zdroj všem autentizovaným požadavkům [@prafauth], implementace komplexnějších přístupových práv je opět možná.

Python REST API framework nabízí určitou strukturu, jak REST API v Pythonu budovat, nenabízí ale velký výběr stavebních kamenů.
Předpokládá se, že programátor si je dobuduje sám, což nepovažuji nutně za špatnou věc. Je však třeba vytknout v současnosti zpomalený vývoj projektu a především absenci podpory pro Python 3. Nízká oblíbenost projektu může být důsledkem těchto problémů.
