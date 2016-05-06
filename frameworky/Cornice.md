Cornice
=======

Cornice je RESTový framework pro Pyramid [@cornice].
Je vyvíjen lidmi z Mozilla Services a vydán pod Mozilla Public License 2.0 [@mpl2],
čímž se řadí do kategorie LGPL.
Závisí na dvou dalších modulech (`pyramid` a `simplejson`),
čímž nepřímo závisí na celkem devíti modulech a zabírá s nimi 12~MiB.
Podporuje obě verze Pythonu. Na GitHubu má 270 hvězd a za poslední měsíc byl stažen 10903krát.

Projekt vznikl v roce 2011 a od té doby vyšla již více než dvacítka verzí.
V době zkoumání byla nejnovější verze pouze několik týdnů stará, proto vývoj hodnotím jako aktivní.
Na vývoji se podílelo celkem více než šest desítek vývojářů, většina z nich formou drobné úpravy, která bývá rychle přijata i od lidí mimo projekt a mimo Mozilla Services.

[V ukázce kódu](#code:cornice) najdete příklad použití Cornice.
V ukázce je definována služba, která umožňuje použít GET a POST na nějakou hondnotu `/values/{value}`, kde `value` reprezentuje ASCII název té hodnoty.

```{caption="{#code:cornice}Příklad použití z dokumentace Cornice \autocite{cornicedoc}" .python}
from cornice import Service

values = Service(name='foo', path='/values/{value}',
                 description="Cornice Demo")

_VALUES = {}


@values.get()
def get_value(request):
    """Returns the value.
    """
    key = request.matchdict['value']
    return _VALUES.get(key)


@values.post()
def set_value(request):
    """Set the value.

    Returns *True* or *False*.
    """
    key = request.matchdict['value']
    try:
        # json_body is JSON-decoded variant of the request body
        _VALUES[key] = request.json_body
    except ValueError:
        return False
    return True
```

HATEOAS
-------

Cornice nenabízí předem připravené mechanismy k prolinkování zdrojů.
Pokud chcete použít JSON API, HAL či další obdobné standardy, budete je muset dodržet a naimplementovat sami.
Cornice nezískává žádný bod.


Přístupová práva
----------------

Cornice nenabízí žádné zabudované možnosti, jak řešit přístupová práva. Ve výchozím stavu je celé API přístupné všem, můžete však napsat vlastní funkci v Pythonu, která práva bude řešit. Toto na jednu stranu nabízí téměř nemezné možnosti, na stranu druhou to není příliš pohodlné. Cornice získává jeden bod.


Cornice působí jako solidní nízkoúrovňový REST framework: Pokud víte, co děláte, můžete pomocí něj neimplementovat REST službu, ale neudělá příliš věcí za vás. Speciální funkcí je pak podpora SPORE[^spore] [@cornicespore].

[^spore]: Specification to a POrtable Rest Environment [@spore]