Nefertari
=========

Nefertari je REST API framework pro Pyramid, který používá Elasticsearch pro čtení a MongoDB nebo PostgreSQL pro zápis [@nefertari].

V Nefertari je nejprve potřeba připravit model, což je entita mapovaná na databázi, a k danému modelu vytvořit pohled, což je mapování dané entity na HTTP metody. Ukázkový model a pohled můžete vidět [v ukázkách](#code:nefertarimodel) [a](#code:nefertariview). Serializaci do JSONu a mapování na URL za vás obstará framework.

```{caption="{#code:nefertarimodel}Příklad použití z dokumentace Nefertari (model) \autocite{nefertarimodel}" .python}
from datetime import datetime
from nefertari import engine as eng
from nefertari.engine import BaseDocument


class Story(BaseDocument):
    __tablename__ = 'stories'

    _auth_fields = [
        'id', 'updated_at', 'created_at', 'start_date',
        'due_date', 'name', 'description']
    _public_fields = ['id', 'start_date', 'due_date', 'name']

    id = eng.IdField(primary_key=True)
    updated_at = eng.DateTimeField(onupdate=datetime.utcnow)
    created_at = eng.DateTimeField(default=datetime.utcnow)

    start_date = eng.DateTimeField(default=datetime.utcnow)
    due_date = eng.DateTimeField()

    name = eng.StringField(required=True)
    description = eng.TextField()
```

```{caption="{#code:nefertariview}Příklad použití z dokumentace Nefertari (pohled) \autocite{nefertariview}" .python}
from nefertari.view import BaseView
from example_api.models import Story


class StoriesView(BaseView):
    Model = Story

    def index(self):
        return self.get_collection_es()

    def show(self, **kwargs):
        return self.context

    def create(self):
        story = self.Model(**self._json_params)
        return story.save(self.request)

    def update(self, **kwargs):
        story = self.Model.get_item(
            id=kwargs.pop('story_id'), **kwargs)
        return story.update(self._json_params, self.request)

    def replace(self, **kwargs):
        return self.update(**kwargs)

    def delete(self, **kwargs):
        story = self.Model.get_item(
            id=kwargs.pop('story_id'), **kwargs)
        story.delete(self.request)

    def delete_many(self):
        es_stories = self.get_collection_es()
        stories = self.Model.filter_objects(es_stories)

        return self.Model._delete_many(stories, self.request)

    def update_many(self):
        es_stories = self.get_collection_es()
        stories = self.Model.filter_objects(es_stories)

        return self.Model._update_many(
            stories, self._json_params, self.request)
```

Nefertari závisí na devíti, nepřímo na osmnácti modulech, což je oproti jiným zkoumaným frameworkům opravdu hodně.
Instalace obsahuje celkem 54~339 řádků kódu. Podporován je Python 2 i 3. Projekt je distribuován pod permisivní Apache licencí [@apache].

První commit v projektu se datuje na březen 2015, jedná se tedy, v době psaní tohoto textu, zhruba o jeden rok starý projekt.
Od té doby vyšlo téměř patnáct verzí, poslední v listopadu 2015. Za projektem stojí startup Brandicted[^brandicted], kromě nich do projektu příliš mnoho lidí nepřispívá.

[^brandicted]: Hlavní služba startupu Brandicted.com je v době psaní tohoto textu nedostupná. Je otázkou, zdali jde o náhodu, nebo má Nefertari nejistou budoucnost. Repozitář na GitHubu (který má 37 hvězd) se přesunul do organizace *ramses-tech*, která ale obsahuje stejné vývojáře jako původní organizace *brandicted*.

HATEOAS
-------

Dokumentace Nefertari se nezmiňuje o způsobu, jak jednotlivé zdroje prolinkovat.
V části *Vize* [@nefertarivision] dokonce přímo říká:

> Pro nás znamená „REST API“ něco jako „HTTP metody namapované na CRUD[^crud] operace nad zdroji popsanými v JSONu“.
> Nesnažíme se o úplný HATEOAS, ani o naplnění akademického ideálu o RESTu.

Nedostává tedy žádné body.

[^crud]: *Create*, *Retrieve*, *Update*, *Delete*

Přístupová práva
----------------

Nefertari používá model autentizace z frameworku Pyramid, pomocí cookies [@nefertariauth], což je pro REST API nevyhovující. Přístupová práva oproti tomu umožňuje nastavit velice variabilně na úrovni jednotlivých operací a zdrojů [@nefertariauth]. Dostává tedy jeden bod.

Nefertari vede k tomu, že se vývojář o některé věci vůbec nemusí starat: jak přesně jsou data uložena v databázi nebo jak se mapují zdroje na URL. To může být velkou výhodou, ale i nevýhodou. Podle dokumentace se zdá, že jednotlivé výchozí chování nelze příliš ovlivnit. Nefertari jistě ušetří mnoho práce za cenu svobody volby. Absence HATEOAS a autentizace pomocí cookies můj pohled na Nefertari příliš nezlepší. Existují jistě situace, kde bude Nefertari velmi vhodná, ale není dostatečně flexibilní pro širokou škálu případů.
