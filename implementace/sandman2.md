sandman2
========


Namapování dat z pohledů na zdroje
----------------------------------

Podle dokumentace sandmanu [@sandman] by mělo stačit spustit příkaz [z ukázky](#code:sandman2:command) a API by se mělo „samo vytvořit“.

```{caption="{#code:sandman2:command}sandman2: Automatické vytvoření REST API"}
$ sandman2ctl 'mysql://uzivatel:heslo@server/databaze'
 * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
```

Pokud ale nechceme použít data z tabulek, ale z pohledů, a potřebujeme ovlivnit názvy zdrojů,
nezbývá nám, než nadefinovat modely ručně pomocí SQLAlchemy modelů.
Model pro `/destinations` můžete vidět [v ukázce](#code:sandman2:mapping).


```{caption="{#code:sandman2:mapping}sandman2: Namapování dat z pohledů na zdroje" .python}
class Destinations(sandman2.model.db.Model):
    __tablename__ = 'v_destination'

    id_destination = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String)
    url = db.Column(db.String)

app = sandman2.get_app(url, user_models=[Destinations], read_only=True)
```
Namapování dat z pohledů na zdroje v sandmanu je
možné,
systematické
a jednoduché, ale ne plně automatické, jak by se z popisu sandmanu mohlo zdát.

Přejmenování položek
--------------------

Pro přejmenování položek stačí provést jednoduchou úpravu modelu.
Jak můžete vidět [v ukázce](#code:sandman2:rename),
stačí přejmenovat třídní atributy a poskytnout konstruktoru `Column` název slupce jako první argument
a název atributu jako argument `key`.

Bohužel sandman2 s tím nepočítá a je potřeba předefinovat metodu,
která vrací v sandmanu název sloupce v tabulce a ne nový název.
Dle mého názoru se jedná o chybu a její opravu jsem navrhl autorovi na GitHubu, zatím bez odezvy.
Vytvořil jsem tedy mixin, který použitým modelům tuto metodu předefinuje (vrchní část [ukázky](#code:sandman2:rename)).

```{caption="{#code:sandman2:rename}sandman2: Přejmenování položek" .python}
class CustomizingMixin(Model):
    '''Mixin that fixes primary_key method'''
    def primary_key(self):
        '''Return the key of the model's primary key field'''
        return list(self.__table__.primary_key.columns)[0].key


class Teachers(CustomizingMixin, db.Model):
    __tablename__ = 'v_lectors'

    id = db.Column('id_lector', db.Integer,
                   primary_key=True, key='id')
    degrees_before = db.Column('title_before', db.String,
                               key='degrees_before')
    first_name = db.Column('name', db.String, key='first_name')
    last_name = db.Column('surname', db.String, key='last_name')
    degrees_after = db.Column('title_behind', db.String,
                              key='degrees_after')
    personal_number = db.Column('pers_number', db.Integer,
                                key='personal_number')
    url = db.Column(db.String)
```

Přejmenování položek v sandmanu je
možné,
do určité míry systematické[^key]
a triviální.

[^key]: Má výhrada zde směřuje k nutnosti opakování názvu atributu. Nutnost předefinovat metodu je patrně nezamýšlená.

Prolinkování zdrojů ve stylu HATEOAS
------------------------------------

Sanman2 odkazy nevytváří automaticky, je ale poměrně jednoduché je vytvořit ručně.
Stačí na modelu předefinovat metodu `to_dict()` a zde linky sestrojit z cizích klíčů.
Přidal jsem tedy upravenou variantu této metody do již vytvořeného mixinu ([ukázka](#code:sandman2:links)).

Narazil jsem na problém, že z cizího klíče sice poznám tabulku, ale ne model.
Vyřešil jsem to tak, že před přidáním modelů do aplikace je registruji do reverzního seznamu podle tabulek
(pomocí dekorátoru),
ale tento způsob se mi příliš nelíbí, sendman2 bohužel žádný vlastní způsob nenabízí.

```{caption="{#code:sandman2:links}sandman2: Prolinkování zdrojů ve stylu HATEOAS" .python}
class CustomizingMixin(Model):
    # ...

    def to_dict(self):
        '''Return the resource as a dictionary'''
        result_dict = {}
        for column in self.__table__.columns:
            name = column.key
            value = result_dict[name] = getattr(self, name, None)
            if column.foreign_keys:
                # Foreign key, turn it to a link, HATEOAS, yay!
                # We always have only one f. key in one column
                fk = list(column.foreign_keys)[0]
                model = modelstore.reverse_lookup(fk.column.table)
                instance = model.query.get(int(value))
                if instance:
                    result_dict[name] = instance.resource_uri()
        result_dict['self'] = self.resource_uri()
        return result_dict
```

Prolinkování zdrojů ve stylu HATEOAS v sandmanu je
možné,
velmi nesystematické,
ale poměrně jednoduché.

Navigační odkazy se automaticky nevytvářejí a úprava tohoto chování není možná.

Úprava zobrazených dat
----------------------

Úpravu zobrazených dat lze provést v metodě `to_dict()`.
Bylo by možné používat různé varianty této metody pro různé modely, ale v našem případě si vystačíme s metodou jednou.
Úpravu pro číselné typy a kód kurzu z KOSu můžete vidět [v ukázce](#code:sandman2:modify).

```{caption="{#code:sandman2:modify}sandman2: Úprava zobrazených dat" .python}
class CustomizingMixin(Model):
    # ...

    def to_dict(self):
        '''Return the resource as a dictionary'''
        result_dict = {}
        for column in self.__table__.columns:
            name = column.key
            value = result_dict[name] = getattr(self, name, None)
            if column.foreign_keys:
                # ...
            elif isinstance(column.type, db.Integer):
                # Return the value as int, otherwise it might
                # get returned as str due to bad SQL type
                result_dict[name] = int(value)
            # ...
        try:
            if not result_dict['_kos_code']:
                result_dict['kos_course_code'] = None
            del result_dict['_kos_code']
        except KeyError:
            pass
        return result_dict
```

Úprava zobrazených dat v sandmanu je
možná,
nepříliš systematická,
ale jednoduchá.

Zobrazení dat ve standardizované podobě
---------------------------------------

Úprava způsobu zobrazení jedné entity je možná v metodě `to_dict()`.
Úprava způsobu zobrazení seznamu entit není možná.

[V ukázce](#sandman2:sandman2:standard) je vidět úprava ve stylu HAL.

```{caption="{#code:sandman2:standard}sandman2: Zobrazení dat ve standardizované podobě" .python}
class CustomizingMixin(Model):
    # ...
    def to_dict(self):
        '''Return the resource as a dictionary'''
        result_dict = {'_links': {}}
        for column in self.__table__.columns:
            name = column.key
            value = result_dict[name] = getattr(self, name, None)
            if column.foreign_keys:
                fk = list(column.foreign_keys)[0]
                model = modelstore.reverse_lookup(fk.column.table)
                instance = model.query.get(int(value))
                if instance:
                    result_dict['_links'][name] = \
                        {'href': instance.resource_uri()}
                    del result_dict[name]
            # ... elifs
            elif isinstance(value, datetime.datetime):
                # Display datetimes in ISO format
                result_dict[name] = value.isoformat()
        result_dict['_links']['self'] = {'href': self.resource_uri()}
        # ...
        return result_dict
```

Příklad výstupu pro HAL můžete vidět [v ukázkce](#code:sandman2:hal).

```{caption="{#sandman2:sandman2:hal}sandman2: Příklad výstupu pro HAL" .python}
{
    "_links": {
        "hall": {
            "href": "/halls/29"
        },
        "self": {
            "href": "/courses/2158"
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

Zobrazení dat ve standardizované podobě v sandmanu je
částečně možné,
nepříliš systematické
a jednoduché v závislosti na zvolené standardu.


Použití přirozených identifikátorů
----------------------------------

Pro použití přirozeného identifikátoru lze v modelu nastavit jiný primární klíč,
následně je v našem případě potřeba v metodě `to_dict()` změnit řádku kódu, která najde patřičný objekt u cizího klíče.
Obojí můžete vidět [v ukázce](#code:sandman2:ids).

```{caption="{#code:sandman2:ids}sandman2: Použití přirozených identifikátorů" .python}
class CustomizingMixin(Model):
    # ...
    def to_dict(self):
        '''Return the resource as a dictionary'''
        # ...
            # WAS: instance = model.query.get(int(value))
            instance = model.query.filter_by(id=int(value)).first()
        # ...
        return result_dict


@modelstore.register
class Sports(mixins.CustomizingMixin, db.Model):
    __tablename__ = 'v_sports'

    id = db.Column('id_sport', db.Integer, key='id')
    shortcut = db.Column('short', db.String, primary_key=True,
                         key='shortcut')
    # ...
```

Použití přirozených identifikátorů v sandmanu je
možné,
systematické
a jednoduché.

Přístupová práva
----------------

Implementace přístupových práv bez velkého zásahu do kódu sandmanu není možná.

Generování dokumentace
----------------------

Sandman2 toto neumožňuje.

Funkce služby
-------------

Dokumentace sandmanu o těchto možnostech mlčí.
Existuje iniciativa za dokumentování těchto funkcí [@sandmanquery].

Zde je také potřeba zmínit, že URI zdrojů fungují jen bez koncového lomítka.

### Stránkování

Je možné pouze zvolit číslo stránky pomocí parametru `page`.
Velikost stránky nelze ovlivnit (je to vždy 20).
Bez použití parametru `page` se implicitně zobrazí celý seznam, což může trvat poměrně dlouho.

`GET /courses?page=5`

Je možné použít parametr `limit` ale ne v kombinaci s parametrem `page`.

`GET /courses?limit=5`

### Filtrování

Filtrovat výsledky se dá pouze velmi omezeným způsobem,
například takto se dá zobrazit seznam kurzů probírajících v pátek:

`GET /courses?day=5`

Neleze ale filtrovat na základě cizích klíčů, ani nastavit podmínku (větší než apod.).
Při špatně provedeném dotazu může výsledek skončit chybou sandmanu, což jsem nahlásil jako chybu.

### Řazení

Je možné použít parametr `sort` pro zvolení položky, podle které se budou výsledky řadit.
Není možné zvolit směr řazení.
Řazení lze kombinovat se stránkováním, ale ne s parametrem `limit`.

`GET /courses?page=1&sort=starts_at`

### Vyjednávání o obsahu

Není v sandmanu podporováno.

### Rozcestník

Není v sandmanu podporován.

Další poznámky
--------------

Pokud máte kontrolu nad databází, nabízí sandman2 jednoduchý automatický způsob, jak vytvořit API alespoň částečně ve stylu REST.
Pokud však potřebujete data prezentovat trochu jiným způsobem, začne sandman2 házet pomyslné klacky pod nohy a základní výhoda
-- tedy automatické vytvoření API --
přestane hrát velkou roli.

Kompletní implementace
----------------------

Kompletní implementaci REST API pro rozvrhová data ÚTVS ČVUT ve frameowkru sandman2
najdete na přiloženém médiu a na adrese
\url{https://github.com/hroncok/utvsapi-sandman}.
