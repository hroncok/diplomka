ripozo
======

![Logo ripoza [@ripozopic]{#pic:ripozo}](images/ripozo)

Ripozo je nástroj pro vytváření RESTful/HATEOAS API.
Poskytuje silné, jednoduché, plně kvalifikované odkazy mezi zdroji; podporuje více protokolů (Siren a HAL).
Ripozo je velmi flexibilní, může ho použít s libovolným webovým frameworkem v Pythonu a libovolnou databází.
[@ripozo]

Základní příklad použití typu *hello world* můžete vidět [v ukázce](#code:ripozo).
V ukázce je vynecháno napojení na webový framework.
Můžete využít existujících knihoven pro napojení na Django a Flask,
či si napsat vlastní třídu pro napojení na jiný webový framework [@ripozo].
Příklad, který přes REST API nabízí kompletní CRUD+L[^crud], pak můžete vidět [v ukázce](#code:ripozocrudl).
Pokud chcete nabízet jen některé akce, můžete použít mixiny[^mixin].

[^crud]: *Create*, *Retrieve*, *Update*, *Delete* a *List* (TODO citovat nějakou chytrou knihu)

[^mixin]: Mixin je třída, kterou v Pythonu použijete jako rodiče, abyste rozšířili funkcionalitu. V tomto konkrétním případě tak například můžete použít mixiny *restmixins.Create* a *restmixins.List* pro poskytnutí akcí pouze pro čtení. (TODO citovat nějakou chytrou knihu)


```{caption="{#code:ripozo}Příklad použití z dokumentace ripoza \autocite{ripozo}" .python}
from ripozo import apimethod, adapters, ResourceBase
# import the dispatcher class for your preferred webframework

class MyResource(ResourceBase):
    @apimethod(methods=['GET'])
    def say_hello(cls, request):
        return cls(properties=dict(hello='world'))

# initialize the dispatcher for your framework
# e.g. dispatcher = FlaskDispatcher(app)
dispatcher.register_adapters(adapters.SirenAdapter,
                             adapters.HalAdapter)
dispatcher.register_resources(MyResource)
```

```{caption="{#code:ripozocrudl}Příklad použití z dokumentace ripoza (CRUD+L) \autocite{ripozo}" .python}
from ripozo import restmixins
from fake_ripozo_extension import Manager
# An ORM model for example a sqlalchemy or Django model:
from myapp.models import MyModel

class MyManager(Manager):
    fields = ('id', 'field1', 'field2',)
    model = MyModel

class MyResource(restmixins.CRUDL):
    manager = MyManager()
    pks = ('id',)

# Create your dispatcher and register the resource...
```

Projekt vznikl v roce 2014, od té doby vyšlo více než třicet verzí, nejnovější asi měsíc před psaním tohoto textu.
Za projektem stojí firma Vertical Knowledge, vyvíjí jej hlavně Tim Martin, ale přispěli i jednotlivci nesouvisející s touto firmou.
Ripozo je distribuováno pod copyleftovou licencí GNU General Public License verze 2 [@GPLv2] nebo vyšší, čímž se odlišuje od naprosté většiny ostatních zde diskutovaných frameworků.

Instalace závisí jen na knihovně six, kvůli kompatibilitě s oběma verzemi Pythonu, a zabírá pouze půl mebibajtu.
Vzhledem k tomu, že instalace samotného ripoza je nepoužitelná, jelikož je potřeba použít nějaký webový framework, je tato informace zavádějící.
Například po instalaci modulů na spolupráci s Flaskem a SQLAlchemy je již závislostí sedm (nepočítaje tři vlastní moduly `ripozo`, `flask-ripozo` a `ripozo-sqlalchemy`) a instalace zabírá 14 MiB.

HATEOAS
-------

Již v úvodu jsem zmínil, že ripozo umožňuje jednoduše vytvářet linky mezi zdroji ve stylu HATEOAS,
a také že ripozo podporuje Siren [@siren] a HAL [@hal]. Představu o vytváření odkazů získáte nejlépe [z ukázky](#code:ripozolink).

```{caption="{#code:ripozolink}Příklad použití z dokumentace ripoza (linkování) \autocite{ripozo}" .python}
from ripozo import restmixins, Relationship

class MyResource(restmixins.CRUDL):
    manager = MyManager()
    pks = ('id',)
    _relationships = [Relationship('related',
                                   relation='RelatedResource')]

class RelatedResource(restmixins.CRUDL)
    manager = RelatedManager()
    pks = ('id',)
```

Přístupová práva
----------------

Ripozo nenabízí přímo žádnou funkcionalitu pro autentizaci či autorizaci.
Obsahuje však možnost předpracovávat požadavky pomocí funkcí.
V dokumentaci se říká, že tímto způsobem můžete například zpřístupnit zdroj pouze autentizovaným uživatelům [@ripozoprepost].

Ripozo je framework, který umožňuje vytvářet RESTful HETEOS API pomocí Siren a HAL, prakticky bez práce. Možnost výběru vlastního frameworku i databáze je velké plus. Nevýhodou může v některých případech být copyleftová licence[^vyhoda].

[^vyhoda]: Richard M. Stallman by určitě namítal, že to je výhodou.
