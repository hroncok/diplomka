Falcon
======

![Logo Falconu [@falconpic]{#pic:falcon}](images/falcon)

Falcon je neuvěřitelně rychlý, minimalistický Python webový framework pro tvorbu cloudových API a aplikačních backendů [@falcon].
Mezi hlavní přednosti podle webové stránky [@falcon] patří:

 * závislost pouze na modulech `six` a `mimeparse`,
 * rychlejší zpracování požadavků než u jiných populárních frameworků,
 * podpora WSGI, CPythonu 2.6, 2.7, 3.3 a 3.4 i PyPy,
 * výkonnost,
 * svoboda volby detailů,
 * spolehlivost.

Falcon je bezesporu minimalistický, společně s závislostmi zabírá pouze 0,9~MiB místa.
Je šířen pod permisivní Apache licencí [@apache] a nevyžaduje žádný webový framework.

Příklad použití můžete vidět [v ukázce](#code:falcon).
Jak je vidět, pomocí Falconu jsou vytvářet REST API, ale jedná se o velmi nízkoúrovňový framework,
který spíše zastává vrstvu mezi HTTP a aplikací, než velkého pomocníka při tvorbě API.

```{caption="{#code:falcon}Příklad použití z webu Falconu \autocite{falcon}" .python}
# sample.py
import falcon
import json

class QuoteResource:
    def on_get(self, req, resp):
        """Handles GET requests"""
        quote = {
            'quote': 'I\'ve always been more interested '
                     'in the future than in the past.',
            'author': 'Grace Hopper'
        }

        resp.body = json.dumps(quote)

api = falcon.API()
api.add_route('/quote', QuoteResource())
```

Projekt vytváří firma Rackspace pod vedením Kurta Griffithse.
Do projektu přispívají i jednotlivci mimo Rackspace.
Vznikl v roce 2012 a od té doby vyšlo celkem 27 vydání.
Dva týdny před psaním tohoto textu vyšla verze 1.0.0rc1, brzy se tedy můžeme těšit na verzi 1.0.0.
Jedná se o aktivní projekt který se může chlubit úplným pokrytím testy [@falconcoverage].

Vzhledem k nízkoúrovnosti frameworku neexistují žádné automatické mechanismy pro správu přístupových práv či HATEOAS.
