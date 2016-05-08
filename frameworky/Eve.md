Eve
===

![Logo Eve [@evepic]{#pic:eve}](images/eve)

Eve je open-source Python REST API framework navržený „pro lidi“.
Umožňuje snadno vytvořit a nasadit vysoce upravitelné, plně funkční RESTful webové služby.
Eve stojí nad nástroji Flask, Redis, Cerberus, Events a podporuje MongoDB i SQL backendy. [@eve]

Eve vychází z následujícího principu: Máte nějaká data a chcete k nim vytvořit REST API,
pokud možno co nejvíce automaticky. Prakticky bez práce nabízí mj. tyto funkce a možnosti [@eveslides]:

 * filtrování,
 * řazení,
 * stránkování,
 * projekce,
 * vnořené zdroje,
 * JSON nebo XML serializaci,
 * HATEOAS,
 * ukládání souborů,
 * limitování přístupu,
 * cache,
 * hromadné vkládání,
 * kontrolu integrity (pomocí ETagu),
 * validaci dat,
 * GeoJSON,
 * autentizaci a autorizaci,
 * podporu obou verzí Pythonu i PyPy,
 * verzování API,
 * generovanou dokumentaci.

Je tedy vidět, že možností je opravdu mnoho. Příklad použití si můžete prohlédnout [v ukázce kódu](#code:eve).

```{caption="{#code:eve}Příklad použití z dokumentace Eve \autocite{evedoc}" .python}
# run.py
from eve import Eve
app = Eve()

if __name__ == '__main__':
    app.run()


# settings.py
DOMAIN = {'people': {}}


# GET /
{
    "_info": {
        "server": "Eve",
        "version": "a.b.c",
        "api_version": "x.y.z"
    },
    "_links": {
        "child": [
            {
                "href": "people",
                "title": "people"
            }
        ]
    }
}


# GET /people
{
    "_items": [],
    "_links": {
        "self": {
            "href": "people",
            "title": "people"
        },
        "parent": {
            "href": "/",
            "title": "home"
        }
    }
}
```

Projekt vznikl v roce 2012, od té doby vyšlo dvacet verzí, poslední cca tři týdny před psaním tohoto textu. Jedná se tedy o aktivní projekt.
Za projektem stojí jednotlivec Nicola Iarocci, přispělo však celkem více než sto dalších přispěvatelů [@evecontributors].
Eve je vydáno pod BSD licencí [@BSD3].

Eve závisí celkem na deseti modulech (včetně Flasku a Werkzeugu), tyto moduly již nemají žádné další závislosti. Celkem se závislostmi má Eve 35~009 řádků kódu. Závislost na Python modulech pro MongoDB není, bohužel, volitelná.

HATEOAS
-------

Eve automaticky prolinkovává jednotlivé zdroje a drží se konceptu HATEOAS [@evehateoas]. Tuto funkci není potřeba speciálně nastavovat ani implementovat, je zapnutá sama od sebe. Každá odpověď na metodu GET obsahuje položku `_links` s odkazy na rodiče, subsekce, předchozí a další stránky apod. Příklad můžete vidět [v ukázce](#code:evehateoas).

Autoři pracují na přímé podpoře pro JSON-LD/HAL/Siren [@eveslides].

Hodnotím v této oblasti Eve třemi body.

```{caption="{#code:evehateoas}Příklad HATEOAS principu z Eve \autocite{evehateoas}" .python}
{
    "_links": {
        "self": {
            "href": "people",
            "title": "people"
        },
        "parent": {
            "href": "/",
            "title": "home"
        },
        "next": {
            "href": "people?page=2",
            "title": "next page"
        },
        "last": {
            "href": "people?page=10",
            "title": "last page"
        }
    }
}
```

Přístupová práva
----------------

Eve umožňuje několik způsobů autentizace, například pomocí tokenu nebo HMAC[^hmac] [@eveauth].
Pomocí externích knihoven je snadné použít OAuth 2 [@eveoauth].

[^hmac]: Hash Message Authentication Code [@hmac]

Eve umožňuje nastavovat přístupová práva podle rolí pro celé API, nebo jen pro některé zdroje, stejně tak pro konkrétní HTTP metody [@eveauth].

Dávám tedy i zde Eve tři body.

Celkově se Eve jeví jako framework s mnoha funkcemi, který dokáže ušetřit velké množství práce. Vytknul bych snad jen přílišnou vázanost na MongoDB, která je často patrná především z dokumentace.
