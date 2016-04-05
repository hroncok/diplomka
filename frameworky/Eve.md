Eve
===

![Logo Eve [@eve]{#pic:eve}](images/eve)

Eve je open-source Python REST API framework navržený pro lidi.
Umožňuje snadno vytvořit a nasadit vysoce upravitelné, plně funkční RESTful webové služby.
Eve stojí nad nástroji Flask, Redis, Cerberus, Events a podporuje MongoDB i SQL backendy. [@eve]


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


# GET /poeple
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