RESTArt
=======

RESTArt je knihovna pro tvorbu REST API. Je inspirovaná Flaskem, ale nezávisí na něm [@restartgh].
Závisí na knihovně Werkzeug a dalších třech modulech, nepřímo tak celkem na pěti.
Instalace má 20~105 řádků kódu.

Projekt vznikl v květnu 2015 a od té doby vyšlo šest verzí. Je stále aktivně vyvíjen,
avšak pouze autorem, jednotlivcem Luem Pengem. Je distribuován pod MIT licencí [@MIT].
Deset hvězd na GitHubu a žádné zapojení jiných vývojářů dává tušit, že nejde o všeobecně známý a používaný projekt.

RESTArt umožňuje vytvářet pro jednotlivé zdroje třídy s metodami korespondujícími s HTTP metodami pro REST API,
příklad z dokumentace můžete vidět [v ukázce](#code:restart).
Je možné vytvářet tz. middleware třídy, které mohou předzpracovávat požadavky a ovlivňovat obsah odpovědí.
Tímto způsobem lze naimplementovat i autentizaci a autorizaci, RESTArt samotný žádné možnosti v této oblasti nepřináší.
Pomocí middleware třídy by mělo jít i nějak automaticky prolinkovat jednotlivé zdroje, dokumentace se o této možnosti ale nijak nezmiňuje.
Dávám tedy u obou kritérií jeden bod.

```{caption="{#code:restart}Příklad použití z dokumentace RESTArtu \autocite{restartqs}" .python}
from restart.api import RESTArt
from restart.resource import Resource

api = RESTArt()

@api.route(methods=['GET'])
class Greeting(Resource):
    name = 'greeting'

    def read(self, request):
        return {'hello': 'world'}
```

RESTArt obsahuje i kód REST klienta, pro účely testování [@restartt].

Kromě Werkzeugu lze požít i jiné webové frameworky, například Flask nebo Falcon [@restartframeworks], případně lze napsat adaptér na jakýkoliv jiný.

RESTArt oproti jiným frameworkům nepřináší nic nového, největší výhodou je možnost vybrat si vlastní webový framework, například pokud již existující součást aplikace nějaký používá.
