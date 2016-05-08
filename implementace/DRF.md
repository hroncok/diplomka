Django REST framework
=====================

Namapování dat z pohledů na zdroje
----------------------------------

Pro namapování dat z pohledů na zdroje je jedním z řešení
vytvořit Django modely, pro ty vytvořit serializační třídy a pohledy.
Django REST framework umožňuje serializovat i data, která nepochází z modelů,
ale to by v tomto případě bylo zbytečně složité.

Jeden model, serializační třídu a pohled můžete vidět [v ukázce](#code:drf:mapping);
implementační detaily, jako importy, jsou vynechány pro lepší čitelnost.
Vzhledem k tomu, že je jednodušší rovnou některé položky přejmenovat,
je v této ukázce již tak učiněno; detailnější vysvětlení najdete v další části.

```{caption="{#code:drf:mapping}DRF: Namapování dat z pohledů na zdroje" .python}
# models.py
class Course(Model):
    id = SmallIntegerField(primary_key=True,
                           db_column='id_subjects')
    shortcut = StringField()
    day = SmallIntegerField()
    starts_at = TinyStringField(db_column='begin')
    ends_at = TinyStringField(db_column='end')
    notice = TextField()
    semester = SmallIntegerField()
    sport = ForeignKey(Sport, db_column='sport')
    hall = ForeignKey(Hall, db_column='hall')
    teacher = ForeignKey(Teacher, db_column='lector')

    class Meta:
        db_table = 'v_subjects'

# serializers.py
class CourseSerializer(HyperlinkedModelSerializer):
    class Meta:
        model = Course
        fields = tuple(
            f.name for f in model._meta.fields \
            if not f.name.startswith('_'))

# views.py
class CourseViewSet(ReadOnlyModelViewSet):
    '''
    API endpoint that allows courses to be viewed.
    '''
    queryset = Course.objects.all()
    serializer_class = CourseSerializer

# urls.py
router = DefaultRouter()
router.register(r'courses', CourseViewSet)
```

Některé kroky, například vytvoření serializační třídy, lze jednoduše automatizovat,
jak je vidět [z ukázky](#code:drf:serializer).
Podobným způsobem by šlo zautomatizovat i vytváření pohledů, ale vzhledem k tomu,
že dokumentační řetězce u pohledů se zobrazují ve webově procházetelném API,
je příhodnější nechat je definované jako jednotlivé třídy.

```{caption="{#code:drf:serializer}DRF: Automatizace vytvoření serializační třídy" .python}
def serializer(model_):
    '''Get a default Serializer class for a model'''
    class _Serializer(HyperlinkedModelSerializer):
        class Meta:
            model = model_
            fields = # ...
    return _Serializer


CourseSerializer = serializer(Course)
```

Namapování dat z pohledů na zdroje v Django REST frameworku je
možné,
systematické
a jednoduché, ale pro tento jednoduchý příklad zbytečně komplexní.

Přejmenování položek
--------------------

Pro přejmenování položek stačí jinak pojmenovat atribut a poskytnout konstruktoru argument `db_column` s názvem sloupce.
Ten je potřeba poskytnout u cizích klíčů i v případě, že se atribut jmenuje stejně jako položka, protože Django jinak očekává,
že se sloupec bude jmenovat `{field}_id`.

Konkrétní příklad přejmenování položek u kurzu můžete vidět [na začátku ukázky](#code:drf:mapping).

Přejmenování položek v Django REST frameworku je
možné,
systematické
a triviální.

Prolinkování zdrojů ve stylu HATEOAS
------------------------------------

Django REST framework při použití `HyperlinkedModelSerializer` automaticky serializuje cizí klíče jako odkazy.


Prolinkování zdrojů ve stylu HATEOAS v Django REST frameworku je
možné, automatické,
systematické
a triviální.

Navigační odkazy se vytvářejí rovněž automaticky.

Úprava zobrazených dat
----------------------

Jednou z variant, jak upravit zobrazená data, je vytvořit přímo v modelu metody,
které budou data měnit a místo původních dat serializovat výsledky těchto metod.
Příklad pro kód předmětu v KOSu můžete vidět [v ukázce](#code:drf:modify).

```{caption="{#code:drf:modify}DRF: Úprava zobrazených dat" .python}
class Enrollment(models.Model):
    # ...
    _kos_course_code = ShortStringField(db_column='kos_kod')
    _kos_code_flag = models.BooleanField(db_column='kos_code')

    @property
    def kos_course_code(self):
        return self._kos_course_code if self._kos_code_flag else None


class EnrollmentSerializer(HyperlinkedModelSerializer):
    class Meta:
        model = Enrollment
        fields = ('kos_course_code', ...) # no _kos_course_code
```

Pokud má model nadefinované některé položky jako číselné, zobrazují se v odpovědích API číselně, takže není nutné je nijak upravovat.

Úprava zobrazených dat v Django REST frameworku je
možná,
systematická
a triviální.

Zobrazení dat ve standardizované podobě
---------------------------------------

Django REST framework data zobrazuje ve velmi jednoduché podobě.
Pokud toto chceme změnit, je třeba vytvořit vlastní třídy zodpovědné za stránkování a prezentaci dat.

Naštěstí již existuje modul `drf-hal-json`, ve kterém existují dané třídy pro HAL serializaci,
jeho použití najdete [v ukázce](#code:drf:standard) a výstup [v ukázce](#code:drf:hal).
Existují i knihovny pro jiné serializace, např. `djangorestframework-jsonapi` pro JSON API.

```{caption="{#code:drf:standard}DRF: Použití modulu drf-hal-json pro HAL" .python}
# settings.py
REST_FRAMEWORK = {
    'DEFAULT_PAGINATION_CLASS':
        'drf_hal_json.pagination.HalPageNumberPagination',
    'DEFAULT_PARSER_CLASSES': ('drf_hal_json.parsers.JsonHalParser',),
    'DEFAULT_RENDERER_CLASSES': (
        'drf_hal_json.renderers.JsonHalRenderer',
        'rest_framework.renderers.BrowsableAPIRenderer',
    ),
    'URL_FIELD_NAME': 'self',
    # ...
}


# serializers.py
def serializer(model_):
    '''Get a default Serializer class for a model'''
    class _Serializer(HalModelSerializer):
        # ...
    return _Serializer
```

```{caption="{#code:drf:hal}DRF: Příklad výstupu pro HAL" .python}
{
    "_links": {
        "self": "http://127.0.0.1:8000/courses/1/",
        "sport": "http://127.0.0.1:8000/sports/3/",
        "hall": "http://127.0.0.1:8000/halls/1/",
        "teacher": "http://127.0.0.1:8000/teachers/6/"
    },
    "id": 1,
    "shortcut": "BAS01",
    "day": 1,
    "starts_at": "13:30",
    "ends_at": "15:00",
    "notice": null,
    "semester": 1
}
```

Zobrazení dat ve standardizované podobě v Django REST frameworku je
možné,
systematické,
ale pracné, naštěstí existují knihovny, které lze rovnou použít.

Použití přirozených identifikátorů
----------------------------------

Pro použití přirozených identifikátorů stačí v pohledu nastavit hodnotu proměnné `lookup_field`
a změnit odkazy vedoucí na daný zdroj, což můžete vidět [v ukázce](#code:drf:ids).
Změna odkazů vyžaduje poměrně mnoho argumentů, které považuji za zbytečné.

```{caption="{#code:drf:ids}DRF: Použití přirozených identifikátorů" .python}
# serializers.py:
class SportSerializer(HyperlinkedModelSerializer):
    self = HyperlinkedIdentityField(
        read_only=True,
        view_name='sport-detail',
        lookup_field='shortcut')
    # ...

class CourseSerializer(HyperlinkedModelSerializer):
    sport = HyperlinkedRelatedField(
        read_only=True,
        view_name='sport-detail',
        lookup_field='shortcut')
    # ...

# views.py:
class SportViewSet(ReadOnlyModelViewSet):
    # ...
    lookup_field = 'shortcut'
```

Použití knihovny `drf-hal-json` v kombinaci s přirozenými identifikátory vede k chybě,
kterou jsem autorům nahlásil. Pokud knihovna `drf-hal-json` není použita, přirozené identifikátory
fungují dle očekávání.

Použití přirozených identifikátorů v Django REST frameworku je
možné,
systematické,
ale zbytečně pracné.

Přístupová práva
----------------

Pro přístupová práva se v Django REST frameworku používají třídy dvojího typu:
autentizační a autorizační.

Pro autentizaci lze použít již poskytnutou třídu `TokenAuthentication` a přepsat
metodu zodpovědnou za validaci tokenu, která vrací informace o uživateli a autorizaci.
Vzhledem k tomu, že uživatelem je zde myšlen model `User` frameworku Django
a zde tento model nepoužívám, protože aplikace přistupuje k databázi v režimu jen pro čtení,
vracím informace o klientu v druhé z návratových hodnot.
Toto můžete vidět [v ukázce](#code:drf:auth).


```{caption="{#code:drf:auth}DRF: Autorizační třída a její použití" .python}
class CtuTokenAuthentication(TokenAuthentication):
    '''
    Simple token based authentication using utvsapitoken.

    Clients should authenticate by passing the token
    key in the 'Authorization' HTTP header,
    prepended with the string 'Token '.  For example:

        Authorization: Token 956e252a-513c-48c5-92dd-bfddc364e812
    '''

    def authenticate_credentials(self, key):
        c = TokenClient()
        try:
            info = c.token_to_info(key)
        except:
            raise exceptions.AuthenticationFailed(
                _('Invalid token.'))
        return (None, info)

# settings.py
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'api.authentication.CtuTokenAuthentication',
    ),
    # ...
}
```

Zde si dovolím malou odbočku.
Třída `TokenAuthentication` z Django REST frameworku očekává v autorizační hlavičce slovo *Token*,
ale RFC 6750 říká, že by to mělo být v případě OAuthu~2 *Bearer* [@rfc6750].
Pokud bych v současnosti chtěl toto změnit, musel bych celý kód třídy zkopírovat a změnit zde právě toto jedno slovo.
Navrhl jsem tedy autorům frameworku úpravu, která umožní příslušné slovo změnit jednodušeji,
tato úprava byla přijata a bude dostupná v další vydané verzi frameworku.

Pro autorizaci a samotná přístupová práva jsem napsal dvě třídy,
jednu obecně pro všechny zdroje, druhou pouze pro zdroj `/enrollments/`,
můžete je vidět [v ukázce](#code:drf:permissions).

```{caption="{#code:drf:permissions}DRF: Třídy pro přístupová práva" .python}
class HasGeneralReadScopeOrIsApiRoot(BasePermission):
    def has_permission(self, request, view):
        if view.get_view_name() == 'Api Root':
            return True
        return (
            request.auth and
            'cvut:utvs:general:read' in request.auth['scope']
        )


class HasEnrollmentsAcces(BasePermission):
    def has_permission(self, request, view):
        if not request.auth:
            return False

        if 'cvut:utvs:enrollments:all' in request.auth['scope']:
            return True

        if ('cvut:utvs:enrollments:by-role' in request.auth['scope']
                and 'B-00000-ZAMESTNANEC' in request.auth['roles']):
            return True

        if ('cvut:utvs:enrollments:personal' in request.auth['scope']
                and 'personal_number' in request.auth):
            # we should check for this in has_object_permission()
            # but it doesn't apply for list queries
            # so filter the queryset instead
            view.queryset = view.queryset.filter(
                personal_number=request.auth['personal_number'])
            return True

        return False


# settings.py
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': (
        'api.permissions.HasGeneralReadScopeOrIsApiRoot',
    ),
    # ...
}


# views.py
class EnrollmentViewSet(*base):
    # ...
    permission_classes = (permissions.HasGeneralReadScopeOrIsApiRoot,
                          permissions.HasEnrollmentsAcces)
```

Přístupová práva v Django REST frameworku jsou
možná,
systematická
a jednoduchá.

Generování dokumentace
----------------------

Django REST framework nabízí webově procházetelná API.
Z dokumentačního hlediska to znamená, že je možné ke každému pohledu napsat dokumentační řetězec,
který bude uživateli u jednotlivých zdrojů zobrazen, jak můžete vidět [na obrázku](#pic:djangorestbrowsableutvs).
Pokud je nainstalován modul `markdown`, lze v dokumentačním řetězci použít jazyk Markdown, který je v procházetelném API nahrazen za patřičné HTML značky.

![DRF: Webově procházetelné API{#pic:djangorestbrowsableutvs}](images/django-rest-framework-browsable-utvs)

Existují také moduly třetích stran, které slouží ke generování dokumentace API [@drfdocstools].

Generování dokumentace v Django REST frameworku je
možné, automatické,
systematické
a triviální.

Funkce služby
-------------


### Stránkování

Stránkování funguje automaticky.
Lze použít parametry `page` a `page_size`.

`GET /courses/?page=2&page_size=10`

### Filtrování

Filtrování nefunguje automaticky a jeho zprovoznění není triviální.
Je potřeba nainstalovat `django-filter`, nastavit výchozí filtrovací backend a na úrovni pohledů specifikovat položky, podle kterých se dá filtrovat.
Což umožňuje velkou kontrolu nad tím, co uživatel smí dělat, ale neumožňuje globálně říct, že se dá všude filtrovat všechno.
Pro filtrovaní všech položek ve všech modelech jsem proto vytvořil mixin, který můžete vidět [v ukázce](#code:drf:filter).

```{caption="{#code:drf:filter}DRF: Mixin pro filtrování podle všech položek" .python}
class FilterAllFieldsMixin:
    @classproperty
    def filter_fields(cls):
        model = cls.serializer_class.Meta.model
        return serializers.fields(model)


base = (ReadOnlyModelViewSet, FilterAllFieldsMixin)


class DestinationViewSet(*base):
    # ...


# settings.py
REST_FRAMEWORK = {
    'DEFAULT_FILTER_BACKENDS': (
        'rest_framework.filters.DjangoFilterBackend',
    ),
    # ...
}
```

Poté jde filtrovat pomocí parametrů v URL.

`GET /courses/?starts_at=07:30`

### Řazení

Řazení není povoleno automaticky, ale jde o jednoduchou úpravu nastavení, kterou můžete vidět [v ukázce](#code:drf:sort).

```{caption="{#code:drf:sort}DRF: Povolení řazení podle URL" .python}
REST_FRAMEWORK = {
    'DEFAULT_FILTER_BACKENDS': (
        'rest_framework.filters.OrderingFilter',
        # ...
    ),
    # ...
}
```

Poté jde položky řadit pomocí parametru `ordering` (název parametru jde v nastavení také změnit).
Je možné řadit vzestupně i sestupně, i podle více klíčů.
Pro seřazení kurzů podle jejich začátku v týdnu od nejpozdějšího lze použít například:

`GET /courses/?ordering=-day,-starts_at`

### Vyjednávání o obsahu

Django REST framework volí patřičnou zobrazovací třídu podle hlavičky `Accept`.
Pokud není použita knihovna `drf-hal-json` je možné nastavovat hlavičkou i způsob odsazování apod.

`GET /courses/1         Accept: application/json; indent=2`

Podobně jde volit serializace do YAMLu nebo XML. Příslušné zobrazovací třídy musí být povoleny v konfiguraci.

### Rozcestník

Django REST framework automaticky vytváří rozcestník.


Další poznámky
--------------

Hlavním problémem Django REST frameworku je zobrazení dat ve standardizované podobě.
Knihovny, které toto umožňují, blokují jinak fungující funkce. Vlastní implementace je příliš obtížná.
Pokud si vystačíte s podobou dat, kterou framework nabízí implicitně, nenarazíte na velký problém.


Kompletní implementace
----------------------

Kompletní implementaci REST API pro rozvrhová data ÚTVS ČVUT v Django REST frameworku
najdete na přiloženém médiu a na adrese:

\url{https://github.com/hroncok/utvsapi-django}
