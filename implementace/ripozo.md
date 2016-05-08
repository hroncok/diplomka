ripozo
======

Namapování dat z pohledů na zdroje
----------------------------------

Pro namapování SQL dat na zdroje je možné použít modul `ripozo-sqlalchemy`.
Je třeba pro každou entitu vytvořit třídy pro model, správce a zdroj.
Příklad pro zdroj `/enrollments` můžete vidět [v ukázce](#code:ripozo:mapping).

```{caption="{#code:ripozo:mapping}ripozo: Namapování dat z pohledů na zdroje" .python}

class Enrollment(db.Model):
    __tablename__ = 'v_students'

    id_student = db.Column(db.Integer, primary_key=True)
    personal_number = db.Column(db.Integer)
    kos_kod = db.Column(db.String)
    utvs = db.Column(db.Integer,
                     db.ForeignKey('v_subjects.id_subjects'))
    semester = db.Column(db.String)
    registration_date = db.Column(db.DateTime)
    tour = db.Column(db.Boolean)
    kos_code = db.Column(db.Boolean)


class EnrollmentManager(AlchemyManager):
    model = Enrollment
    fields = ('id_student', 'personal_number', 'kos_kod', 'utvs',
              'semester', 'registration_date', 'tour', 'kos_code')


class PersonResource(restmixins.RetrieveRetrieveList):
    manager = EnrollmentManager(session_handler)
    pks = ('id_student',)
    resource_name = 'enrollments'


dispatcher.register_resources(PersonResource)
```

`ripozo-sqlalchemy` také nabízí funkci `create_resource()`, která přijímá model a automaticky vytvoří třídy pro správce a zdroj.
Nepřišla mi ale dostatečně flexibilní, tak jsem si podobnou napsal sám,
ve formě dekorátoru, který můžete vidět [v ukázce](#code:ripozo:register).

```{caption="{#code:ripozo:register}ripozo: Dekorátor pro registraci modelů" .python}
resources = {}

def register(cls):
    '''Create default Manager and Resource class for model
    and register it'''
    fields = tuple(
        f for f in cls.__dict__.keys() if not f.startswith('_'))
    pks = getattr(cls, '__pks__', ('id',))

    manager_cls = type(cls.__name__ + 'Manager',
                       (AlchemyManager,),
                       {'fields': fields,
                        'model': cls})

    resource_cls = type(cls.__name__ + 'Resource',
                        (restmixins.RetrieveRetrieveList,),
                        {'manager': manager_cls(session_handler),
                         'resource_name': cls.__name__.lower() + 's',
                         'pks': pks})

    resources[cls.__name__] = resource_cls
    return cls

# later:
dispatcher.register_resources(*resources.values())
```

Při použití dekorátoru `@register` tak stačí vytvořit pouze třídu pro model,
v případě, že se primární klíč nejmenuje *id*, je potřeba nastavit jeho název do třídního atributu `__pks__`.

Nutnost vytvořit tři třídy pro každý zdroj se může jevit přehnaná, umožňuje to ale velkou míru přizpůsobení,
například pokud by každý zdroj byl namapován na jinou databázi apod.

Namapování dat z pohledů na zdroje v ripozu je
možné,
systematické
a pro jednoduché aplikace příliš komplexní, ale ne příliš složité.

Přejmenování položek
--------------------

Pro přejmenování položek stačí provést jednoduchou úpravu modelu.
Jak můžete vidět [v ukázce](#code:ripozo:rename),
stačí přejmenovat třídní atributy a poskytnout konstruktoru `Column` název sloupce jako první argument.

```{caption="{#code:ripozo:rename}ripozo: Přejmenování položek" .python}
@register
class Teacher(db.Model):
    __tablename__ = 'v_lectors'

    id = db.Column('id_lector', db.Integer, primary_key=True)
    degrees_before = db.Column('title_before', db.String)
    first_name = db.Column('name', db.String)
    last_name = db.Column('surname', db.String)
    degrees_after = db.Column('title_behind', db.String)
    personal_number = db.Column('pers_number', db.Integer)
    url = db.Column(db.String)
```

Přejmenování položek v ripozu je
možné,
systematické
a triviální.

Prolinkování zdrojů ve stylu HATEOAS
------------------------------------

Pro prolinkování zdrojů je potřeba:

 1. Přidat do modelu další atribut reprezentující vztah/odkaz.
 2. Přidat vztah do atributu `_relationships` třídy zdroje.

Což jde také udělat automaticky, pokud data dodržují nějakou jmennou konvenci.
Automatický způsob, který předpokládá, že cizí klíče jsou pojmenované jako `{model}_id`,
můžete vidět [v ukázce](#code:ripozo:links).

```{caption="{#code:ripozo:links}ripozo: Automatické vytvoření odkazů" .python}
def fk_magic(cls, fields):
    '''Create links automagically'''
    fks = tuple(field for field in fields if field.endswith('_id'))
    rels = []
    for fk in fks:
        unfk = fk[:-3]  # foo_id -> foo
        setattr(cls, unfk,
                relationship(unfk.title(),
                             foreign_keys=(getattr(cls, fk),)))
        rels.append(Relationship(unfk,
                                 property_map={fk: 'id'},
                                 relation=unfk.title() + 'Resource'))
    return tuple(rels)  # must be a tuple

def register(cls):
    # ...
    rels = fk_magic(cls, fields)
    
    # ...
    resource_cls = type(..., {'_relationships': rels, ...})
    
    # ...
    return cls


@register
class Course(db.Model):
    __tablename__ = 'v_subjects'

    id = db.Column('id_subjects', db.Integer,
                   primary_key=True)
    # ...
    sport_id = db.Column('sport', db.Integer,
                         db.ForeignKey('v_sports.id_sport'))
    hall_id = db.Column('hall', db.Integer,
                        db.ForeignKey('v_hall.id_hall'))
    teacher_id = db.Column('lector', db.Integer,
                           db.ForeignKey('v_lectors.id_lector'))
```

Prolinkování zdrojů ve stylu HATEOAS v ripozu je
možné,
systematické,
ale zbytečně komplexní.

Navigační odkazy se vytvářejí podle druhu výstupu automaticky.

Úprava zobrazených dat
----------------------

Ripozo nabízí *preprocesory* a *postprocesory*,
které jdou použít pro úpravu zobrazených dat.

Postprocesor v našem případě musíme aplikovat pro požadavek na jeden zdroj i pro požadavek na seznam zdrojů.
Bohužel se oba takové postprocesory musí chovat trochu jinak, naštěstí to jde také automatizovat.
[V ukázce](#code:ripozo:modify) je posprocesor pro kód kurzu z KOSu i dekorátor, který způsobí,
že bude korektně aplikován v obou výše zmíněných případech.
Pre- a postprocesory se nastavují ve třídě zdroje, proto je v ukázce i drobná úprava dekorátoru `@register`.


```{caption="{#code:ripozo:modify}ripozo: Úprava zobrazených dat" .python}
def register(cls):
    # ...
    pres = getattr(cls, '__preprocessors__', tuple())
    posts = getattr(cls, '__postprocessors__', tuple())

    resource_cls = type(..., {'preprocessors': pres,
                              'postprocessors': posts,
                              ...})
    # ...
    return cls

def onemany(func):
    '''
    Decorator for postprocessors in order to run a given function
    an all resources
    '''
    def processor(cls, function_name, request, resource):
        if function_name == 'retrieve':
            return func(cls, function_name, request, resource)
        if function_name == 'retrieve_list':
            for one in resource.related_resources[0].resource:
                func(cls, 'retrieve', request, one)
    return processor


@register
class Enrollment(db.Model):
    # ...
    kos_course_code = db.Column('kos_kod', db.String)
    kos_code_flag = db.Column('kos_code', db.Boolean)

    @onemany
    def _post_kos_code_null(cls, function_name, request, resource):
        '''This will be called as a function, so no self!'''
        if not resource.properties['kos_code_flag']:
            resource.properties['kos_course_code'] = None
        del resource.properties['kos_code_flag']

    __postprocessors__ = (_post_kos_code_null,)
```

Úprava zobrazených dat v ripozu je
možná,
systematická
a jednoduchá.

Zobrazení dat ve standardizované podobě
---------------------------------------

Jednou z hlavních výhod ripoza je integrovaná podpora pro HAL, Siren i JSON API.
Jednotlivé formáty lze použít dokonce zároveň, zvolen je takový, o který si klient zažádá,
případně první v pořadí registrace ([ukázka](#code:ripozo:standard)).

```{caption="{#code:ripozo:standard}ripozo: Zobrazení dat ve standardizované podobě" .python}
dispatcher.register_adapters(adapters.HalAdapter,
                             adapters.SirenAdapter,
                             adapters.JSONAPIAdapter,
                             adapters.BasicJSONAdapter)
```

Příklad výstupu pro HAL můžete vidět [v ukázkce](#code:ripozo:hal).

```{caption="{#code:ripozo:hal}ripozo: Příklad výstupu pro HAL" .python}
{
    "_embedded": {},
    "_links": {
        "hall": {
            "href": "/halls/29"
        },
        "self": {
            "href": "http://127.0.0.1:5000/courses/2158"
        },
        "sport": {
            "href": "/sports/107"
        },
        "teacher": {
            "href": "/teachers/42"
        }
    },
    "day": 5,
    "ends_at": "15:30",
    "id": 2158,
    "notice": "P\u0158KS /k\u00f3dy 17PBPTV2 a 17BPTV2/ - sebeobrana",
    "semester": 2,
    "shortcut": "FBM14",
    "starts_at": "14:00"
}
```

Zobrazení dat ve standardizované podobě v ripozu je
možné,
systematické
a automatické.

Použití přirozených identifikátorů
----------------------------------

Pro použití přirozených identifikátorů stačí změnit primární klíč, jak můžete vidět [v ukázce](#code:ripozo:ids).

```{caption="{#code:ripozo:ids}ripozo: Použití přirozených identifikátorů" .python}
@register
class Sport(db.Model):
    __tablename__ = 'v_sports'
    __pks__ = ('shortcut',)

    id = db.Column('id_sport', db.Integer, primary_key=True)
    shortcut = db.Column('short', db.String)
    name = db.Column('sport', db.String)
    description = db.Column(db.String)
```

Bohužel pak přestanou fungovat odkazy, jelikož ripozo v momentě konstrukce odkazu zná pouze sloupec, na který je odkaz vázán (což je zde *id* a ne *shortcut*).

Použití přirozených identifikátorů v ripozu je sice
možné,
systematické
a triviální, ale rozbije to jinou část.

Přístupová práva
----------------

Ripozo nepřináší žádný zabudovaný mechanismus pro správu přístupových práv,
podle dokumentace je na to vhodné použít pre- a postprocesory [@ripozoprepost].

Vytvořil jsem tedy hlavní preprocesor, který v dekorátoru `@register` vkládám ke všem zdrojům.
Tento preprocesor ověří token pomocí modulu `utvsapitoken` a vyhodnotí, jestli má klient právo ke čtení.
Preprocesor můžete vidět [v ukázce](#code:ripozo:auth). Použité třídy výjimek jsem si musel vytvořit, ale kvůli trivialitě je zde neuvádím.
Ripozo zařídí, že se výjimky správně projeví v odpovědi serveru (stavovým kódem a zprávou o chybě).

```{caption="{#code:ripozo:auth}ripozo: Autorizační preprocesor" .python}
def headers_to_token(headers, *, authorization='authorization',
                     bearer='Bearer '):
    '''
    Get the auth token form the headers

    Returns None if not found
    '''
    if authorization in headers:
        header = headers[authorization]
        if header.startswith(bearer):
            return header[len(bearer):].strip()


def preprocessor(cls, function_name, request):
    token = headers_to_token(request.headers)
    if not token:
        raise exceptions.UnauthorizedException(
            'Token not provided. Use the following header: '
            'Authorization: Bearer {token}')
    c = TokenClient()

    try:
        info = c.token_to_info(token)
    except:
        raise exceptions.UnauthorizedException(
            'Token not valid. Please provide a valid token.')

    # default behavior for all of our resources
    if 'cvut:utvs:general:read' not in info['scope']:
        raise exceptions.ForbiddenException(
            'Permission denied. You need '
            'cvut:utvs:general:read scope.')

    # add the information to the request,
    # for further pre/postprocessors
    request.client_info = info
```

Pro komplikovanější logiku je třeba přidat pre-/postprocesor na úrovni zdroje.
U zdroje `/enrollments` musíme zajistit, že data uvidí jen speciálně autorizované klienty.
Pro výpis zápisů je třeba použít preprocesor, pro konkrétní zápis je třeba použít postprocesor,
abychom mohli přistupovat ke zdroji a zjistit, jakému studentovi náleží apod.

V [ukázce](#code:ripozo:auth2) můžete vidět zjednodušenou variantu funkce,
která slouží zároveň jako preprocesor i jako postprocesor.
Kompletní kód včetně vysvětlujících komentářů je součástí implementace služby.

```{caption="{#code:ripozo:auth2}ripozo: Autorizační pre-/postprocesor zdroje Enrollment" .python}
class Enrollment(db.Model):
    # ...

    def _prepost_auth_logic(cls, message, request, resource=None):
        scope = request.client_info['scope']

        # can read anything
        if 'cvut:utvs:enrollments:all' in scope:
            return

        if 'cvut:utvs:enrollments:by-role' in scope:
            if 'B-00000-ZAMESTNANEC' in request.client_info['roles']:
                return

        if 'cvut:utvs:enrollments:personal' in scope:
            pnum = request.client_info['personal_number']
            if not pnum:
                raise exceptions.ForbiddenException(
                    'Permission denied.')

            if resource:
                # this is one resource
                # you are the student of this resource
                if pnum == resource.properties['personal_number']:
                    return
            else:
                # this is a list of resources
                # you are a person, but not a teacher
                # we'll filter all the enrollments by personal_number
                request.query_args.update({'personal_number': [pnum]})
                return

        # out of options
        raise exceptions.ForbiddenException('Permission denied.')
```

Přístupová práva v ripozu jsou
možná,
částečně systematická,
ale pro složitější logiku mohou být příliš komplikovaná.

Generování dokumentace
----------------------

Ripozo toto neumožňuje.

Funkce služby
-------------

Dokumentace ripoza neuvádí nic o možnostech stránkování, filtrování apod.
Prohlídkou kódu jsem zjistil, že tyto možnosti obstarává `ripozo-sqlalchemy`,
který dokumentací spíše šetří, informace zde uvedené jsou tedy získány experimentálně.

### Stránkování

Stránkovat se dá standardně pomocí parametrů `count` a `page`.

`GET /courses/?page=5&count=5`

### Filtrování

Filtrovat výsledky se dá pouze jednoduchým způsobem,
například takto se dá zobrazit seznam kurzů probíhajících v pátek:

`GET /courses/?day=5`

Nelze ale filtrovat na základě cizích klíčů, ani nastavit podmínku (větší než apod.).
Při špatně provedeném dotazu může výsledek skončit chybou ripoza, což jsem nahlásil jako chybu,
na jejíž opravě již autor `ripozo-sqlalchemy` pracuje.

Filtrování a stránkování se dá kombinovat, je možné použít více filtrů.
Navigační odkazy na další stránky neobsahují použitý filtr, což jsem nahlásil jako chybu.

### Řazení

Nepřišel jsem na způsob, jak seznam řadit jinak než implicitně.
Zde je třeba zdůraznit, že se jedná o nedostatek modulu `ripozo-sqlalchemy`.

### Vyjednávání o obsahu

Podle hlavičky `Accept` volí ripozo vhodný *adaptér* (HAL, Siren atd.).

### Rozcestník

Rozcestník je automaticky vytvořen, odpovídá ale pouze na metodu *OPTIONS*.

### Seznam položek

Zásadním nedostatkem služby je nemožnost zobrazení seznamu položek jinak, než formou odkazů.
To vede k nutnosti zaslání $N+1$ dotazů, pokud potřebujme získat informace o $N$ položkách,
u jiných implementací k tomu stačí jeden dotaz.

Další poznámky
--------------

Při implementaci byl použit *dispatcher* pro Flask. Ripozo umožňuje využití jiných frameworků,
ale v současné době je k dispozici pouze navázání na Flask a Django.

Vzhledem k výsledkům benchmarku [v části](#benchmark@) by bylo z hlediska rychlosti zajímavé implementovat napojení na webový framework Falcon.
Jelikož se tato práce ale obecně rozdíly mezi webovými frameworky nezabývá, nechávám tuto možnost otevřenou.


Kompletní implementace
----------------------

Kompletní implementaci REST API pro rozvrhová data ÚTVS ČVUT ve frameworku ripozo
najdete na přiloženém médiu a na adrese:

\url{https://github.com/hroncok/utvsapi-ripozo}
