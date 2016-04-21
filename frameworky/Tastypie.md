Tastypie
========

![Logo Tastypie [@tastypie]{#pic:tastypie}](images/tastypie)

Tastypie je framework pro vytváření API k webovým službám určený pro Django.
Poskytuje abstrakci pro vytváření rozhraní ve stylu REST.
Zjednodušuje zveřejňování modelů a umožňuje vybrat, které části budou přes API přístupné.
Kromě ORM dat je možné použít i jiné zdroje. [@tastypie]

Mezi hlavní funkce patří [@tastypie]:

 * podpora HTTP metod GET, POST, PUT, DELETE a PATCH;
 * rozumné chování ve výchozím stavu;
 * rozšířitelnost;
 * podpora různých serializačních formátů (JSON/XML/YAML/bplist);
 * HATEOAS;
 * dobré testy a dokumentace.

Projekt vznikl již v roce 2010, od té doby vyšlo více než dvacet verzí, poslední o něco málo než měsíc před psaním tohoto textu.
Autorem projektu je jednotlivec Daniel Lindsley, který se projektu již příliš nevěnuje, v současnosti se o něj stará Seán Hayes,
přispělo celkem více než 150 přispěvatelů. Projekt je distribuován pod permisivní BSD licencí [@BSD3].

Pokud si vystačíte s JSON serializací, závisí Tastypie přímo na třech, nepřímo na čtyřech modulech a zabírá 41~MiB.
Pro použití XML, YAML nebo bplistu je potřeba nainstalovat další moduly. Tastypie funguje na Pythonu 2 i 3 a podporuje poslední verze Djanga.

### HATEOAS

Příklad použití můžete vidět [v ukázkách](#code:tastypie) [a](#code:tastypie2).
Přímo v tomto příkladu vznikne prolinkování mezi zdroji pomocí URL.

```{caption="{#code:tastypie}Příklad použití z dokumentace Tastypie (api.py) \autocite{tastypiedoc}" .python}
from django.contrib.auth.models import User
from tastypie import fields
from tastypie.resources import ModelResource
from myapp.models import Entry


class UserResource(ModelResource):
    class Meta:
        queryset = User.objects.all()
        resource_name = 'user'


class EntryResource(ModelResource):
    user = fields.ForeignKey(UserResource, 'user')

    class Meta:
        queryset = Entry.objects.all()
        resource_name = 'entry'
```

```{caption="{#code:tastypie2}Příklad použití z dokumentace Tastypie (urls.py) \autocite{tastypiedoc}" .python}
from django.conf.urls import url, include
from tastypie.api import Api
from myapp.api import EntryResource, UserResource

v1_api = Api(api_name='v1')
v1_api.register(UserResource())
v1_api.register(EntryResource())

urlpatterns = [
    # The normal jazz here...
    url(r'^blog/', include('myapp.urls')),
    url(r'^api/', include(v1_api.urls)),
]
```

### Přístupová práva

Tastypie umožňuje autentizaci přes HTTP jméno a heslo, pomocí API klíče, session a OAuth 1; lze si také dopsat vlastní způsob [@tastypieauth].
Existují moduly třetích stran přidávající podporu OAuth 2 [@tastypieoath].
Na úrovni zdrojů lze pak nastavit, jaký autorizační model se použije, k dispozici je buďto varianta povolit všechno, nebo povolit jen číst, případně lze použít propracovanější systém Djanga, který mapuje práva uživatele na konkrétní objekty; implementace vlastní logiky je také možná [@tastypieauto].

Tastypie se jeví jako velmi použitelný framework pro Django. Důstojně konkuruje Django REST Frameworku, o kterém jsem psal [v části](#django-rest-framework).
Případná volba mezi těmito dvěma frameworky hodně závisí na konkrétních potřebách a preferencích uživatele.