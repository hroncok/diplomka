Ramses (rozšíření pro Nefertari)
================================

![Logo Ramsesu [@ramses]{#pic:ramses}](pdfs/ramses)

Ramses je framework, který generuje RESTful API pomocí RAMLu [^raml].
Používá Pyramid a Nefertari [@ramsesdoc].

[^raml]: *RESTful API Modeling Language*, postavený na YAMLu [@raml]

Ramses přináší stejné funkce jako Nefertari, o které jsem psal [v části](#nefertari).
Místo kódu v Pythonu se však používá deskriptivní jazyk RAML.

Ramses přímo závisí na sedmi modulech, nepřímo pak na téměř třiceti, instalace má celkem 68~594 řádků kódu.
V počtu závislostí je tak v negativním slova smyslu vítězem.

Projekt vytváří stejní autoři jako Nefertari a všechny informace o aktivitě jsou prakticky stejné,
projekt vznikl na přelomu února a března 2015, poslední z dvanácti verzí vyšla v listopadu téhož roku.
Kód je distribuován pod permisivní Apache licencí [@apache], stejně jako Nefertari.
Na rozdíl od Nefertari má na GitHubu více než dvě stovky hvězd.

Zkrácený příklad RAML souboru pro vytvoření API můžete vidět [v ukázce](#code:ramses).
V odpovědi [v ukázce](#code:ramsesreply) pak můžete vidět absenci prolinkování.

```{caption="{#code:ramses}Příklad použití Ramsesu \autocite{ramsespizza}" .yml}
#%RAML 0.8
---
title: pizza_factory API
documentation:
    - title: pizza_factory REST API
      content: |
        Welcome to the pizza_factory API.
baseUri: http://{host}:{port}/{version}
version: v1
mediaType: application/json
protocols: [HTTP]

/cheeses:
    displayName: Collection of different cheeses
    get:
        description: Get all cheeses
    post:
        description: Create a new cheese
        body:
            application/json:
                schema: !include schemas/cheeses.json

    /{id}:
        displayName: A particular cheese ingredient
        get:
            description: Get a particular cheese
        delete:
            description: Delete a particular cheese
        patch:
            description: Update a particular cheese

/pizzas:
    displayName: Collection of pizza styles
    get:
        description: Get all pizza styles
    post:
        description: Create a new pizza style
        body:
            application/json:
                schema: !include schemas/pizzas.json

    /{id}:
        displayName: A particular pizza style
        get:
            description: Get a particular pizza style
        delete:
            description: Delete a particular pizza style
        patch:
            description: Update a particular pizza style

# ...
```

```{caption="{#code:ramsesreply}Odpověď Ramsesu \autocite{ramsespizza}" .python}
# POST /api/pizzas name=hawaiian toppings:=[1,2] ...
{
    "data": {
        "_type": "Pizza",
        "_version": 0,
        "cheeses": [
            1
        ],
        "crust": 1,
        "crust_id": 1,
        "description": null,
        "id": 1,
        "name": "hawaiian",
        "sauce": 1,
        "sauce_id": 1,
        "self": "http://localhost:6543/api/pizzas/1",
        "toppings": [
            1,
            2
        ],
        "updated_at": null
    },
    "explanation": "",
    "id": "1",
    "message": null,
    "status_code": 201,
    "timestamp": "2015-06-05T18:47:53Z",
    "title": "Created"
}
```

Vzhledem k tomu, že Ramses je abstrakční vrstva nad Nefertari, nebudu zde opakovat sekce o HATEOAS a přístupových právech, jelikož by byly prakticky stejné.
Vytváření REST API pomocí RAML souborů je možná směr, kterým se v budoucnu lidstvo vydá, ale bojím se, že na Ramsesu je třeba ještě zapracovat.
Otázkou je, jestli bude nebo nebude dále vyvíjen.