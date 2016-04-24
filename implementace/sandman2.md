
Sandman2
========

Základní použití s nástrojem sandman2ctl
----------------------------------------

Podle dokumentace sandmanu [@sandman] by mělo stačit spustit příkaz [z ukázky](#code:sandman2:command) a API by se mělo „samo vytvořit“.

```{caption="{#code:sandman2:command}Sandman2: Automatické vytvoření REST API"}
$ sandman2ctl 'mysql://uzivatel:heslo@server/databaze'
UserWarning: SQLALCHEMY_TRACK_MODIFICATIONS adds significant overhead 
and will be disabled by default in the future.  Set it to True to supp
ress this warning.
 * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
```

Kromě varování ohledně funkce z SQLAlchemy, která bude v budoucnosti vypnuta, se zdá, že všechno proběhlo,
jak má, a API je připraveno k použití.
Například na adrese `/v_destination` bychom tedy měli dostat seznam všech destinací.
Bohužel, to se neděje, jak můžete vidět [v ukázce](#code:sandman2:get1).

```{caption="{#code:sandman2:get1}Sandman2: Chyba 404"}
$ curl http://127.0.0.1:5000/v_destination
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<title>404 Not Found</title>
<h1>Not Found</h1>
<p>The requested URL was not found on the server.  If you entered the 
URL manually please check your spelling and try again.</p>
```

Přišel jsem na to, že sandman2 zobrazuje pouze všechny SQL tabulky, nezobrazí pohledy.
Pokud tedy v databázi budou tabulky, sandman2 je zobrazí správně.
[V příkladech](#code:sandman2:get2) [a](#code:sandman2:get3)  existuje v databázi tabulka `destination` se stejnou strukturou jako má pohled `v_destination`.

```{caption="{#code:sandman2:get2}Sandman2: Seznam destinací"}
$ curl http://127.0.0.1:5000/destination
{
  "resources": [
    {
      "id_destination": 0,
      "name": "name",
      "url": "url"
    },
    {
      "id_destination": 4,
      "name": "Benecko - Penzion Villa",
      "url": "http://www.utvs.cvut.cz/zimni-kurzy/destinace/benecko-p
enzion-villa.html"
    },
    {
      "id_destination": 6,
      "name": "\u0160pindler\u016fv Ml\u00fdn - Lovochemie",
      "url": "http://www.utvs.cvut.cz/zimni-kurzy/destinace/spindleru
v-mlyn-lovochemie.html"
    },
    ... vynecháno
    {
      "id_destination": 110,
      "name": "Orl\u00edk - placht\u011bn\u00ed",
      "url": ""
    }
  ]
}
```

```{caption="{#code:sandman2:get3}Sandman2: Jedna destinace"}
$ curl http://127.0.0.1:5000/destination/53
{
  "id_destination": 53,
  "name": "Chorvatsko - Rab",
  "url": "http://www.utvs.cvut.cz/letni-kurzy/destinace/chorvatsko-rab
.html"
}
```

Pokročilé použití z Pythonu
---------------------------

Rozhodl jsem se tedy vyzkoušet nějaké možnosti úpravy chování a přesvědčit sandman2 k zobrazení dat z pohledů.
Nejprve jsem vytvořil jednoduchý skript ([ukázka](#code:sandman2:py1)), který by se měl chovat podobně jako `sandman2ctl`;
s jediným rozdílem -- rovnou jsem využil možnosti `read_only`, které zpřístupní pouze metody pro čtení.

```{caption="{#code:sandman2:py1}Sandman2: Použití z Pythonu" .python}
import sandman2
from sqlalchemy.engine.url import URL

# to use this, create mysql.cnf with content like this:
# [client]
# host = localhost
# user = foo
# database = bar
# password = secret

url = URL('mysql', query={'read_default_file': './mysql.cnf'})
app = sandman2.get_app(url, read_only=True)

app.run()
```

Ověřil jsem, že se skript chová stejně jako `sandman2ctl`.
Poté jsem vytvořil vlastní model a pokusil se ho namapovat na pohled místo tabulky ([ukázka](#code:sandman2:py2)).

```{caption="{#code:sandman2:py2}Sandman2: Pokus o vlastní model" .python}
class Destinations(sandman2.model.db.Model):
    __tablename__ = 'v_destination'


app = sandman2.get_app(url, user_models=[Destinations], read_only=True)
```

To bohužel selže s výjimkou, protože při použití vlastního modelu je nutné specifikovat jednotlivé sloupce z tabulky ([ukázka](#code:sandman2:py3)).
Obrovská část automatiky tak bohužel ze sandmanu zmizí.

```{caption="{#code:sandman2:py3}Sandman2: Vlastní model" .python}
from sandman2.model import db


class Destinations(db.Model):
    __tablename__ = 'v_destination'
    id_destination = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String)
    url = db.Column(db.String)
```

Při použití vlastního modelu již je možné data číst ze zdroje `/destinations`.

Úpravy
------

Některé názvy atributů je třeba přejmenovat.
Sandman2 k tomu nedává žádnou jinou možnost, než předefinovat u modelu metodu `to_dict`,
která bude použita před serializací dat do JSONu.
Vytvořil jsem tedy mixin, který upraví prezentovaná data podle slovníku `__renames__` v modelu ([ukázka](#code:sandman2:py4)).

```{caption="{#code:sandman2:py4}Sandman2: Přejmenování atributů" .python}
class CustomizingMixin(Model):
    '''Mixin that adds customization for the output'''
    def _rename(self, column):
        '''Return a new name for a column'''
        try:
            return self.__renames__[column]
        except (AttributeError, KeyError):
            return column

    def to_dict(self):
        '''Return the resource as a dictionary'''
        result_dict = {}
        for column in self.__table__.columns:
            name = self._rename(column.key)
            value = result_dict[name] = getattr(self, column.key, None)
        return result_dict


class Courses(CustomizingMixin, db.Model):
    __tablename__ = 'v_subjects'
    __renames__ = {
        'id_subjects': 'id_course',
        'lector': 'teacher',
    }

    id_subjects = db.Column(db.Integer, primary_key=True)
    sport = db.Column(db.Integer, db.ForeignKey('v_sports.id_sport'))
    shortcut = db.Column(db.String)
    day = db.Column(db.Integer)
    begin = db.Column(db.String)
    end = db.Column(db.String)
    hall = db.Column(db.Integer, db.ForeignKey('v_hall.id_hall'))
    lector = db.Column(db.Integer,
                       db.ForeignKey('v_lectors.id_lector'))
    notice = db.Column(db.String)
    semester = db.Column(db.Integer)
```

Je třeba zdůraznit, že toto řešení (úprava na prezentační vrstvě) funguje pouze pro čtení dat,
v případě, že by k přejmenování mělo dojít i při zápisu,
muselo by dojít k dalším úpravám.

Existuje i přímočařejší způsob, který můžete vidět [v ukázce](#code:sandman2:py45),
ten ale rozbije konstrukci URI pro jednotlivé zdroje i procházení atributů v metodě `to_dict`,
protože sandman2 hledá sloupce podle názvů v SQL, ale vidí data na úrovni názvu atributů.
Celkově se zdá, že je to použití, které autor sandmanu nezamýšlel, lepší by samozřejmě bylo mít takto sloupce pojmenované už v databázi.

```{caption="{#code:sandman2:py45}Sandman2: Jiný způsob přejmenování" .python}
class Courses(CustomizingMixin, db.Model):
    __tablename__ = 'v_subjects'

    id_course = db.Column('id_subjects', db.Integer, primary_key=True)
    teacher = db.Column('lector', db.Integer,
                        db.ForeignKey('v_lectors.id_lector'))
    # ...
```

Navzdory očekávání sandman2 nevytvořil odkazy podle cizích klíčů.
Zároveň některá číslená data zobrazoval jako stringy, protože tak byla uložena v databázi.
Toto šlo také upravit v metodě `to_dict` ([ukázka](#code:sandman2:py5)).
Výsledek můžete vidět [v ukázce](#code:sandman2:get4).

```{caption="{#code:sandman2:py5}Sandman2: Přidání prolinkování a další úpravy" .python}
if column.foreign_keys:
    # Foreign key, turn it to a link, HATEOAS, yay!
    # We always have only one f. key in one column
    fk = list(column.foreign_keys)[0]
    model = modelstore.reverse_lookup(fk.column.table)
    instance = model.query.get(int(value))
    if instance:
        result_dict[name] = instance.resource_uri()
elif isinstance(column.type, db.Integer):
    # Return the value as int, otherwise it might
    # get returned as str due to bad SQL type
    result_dict[name] = int(value)
elif isinstance(value, datetime.datetime):
    # Display datetimes in ISO format
    result_dict[name] = value.isoformat()
result_dict['self'] = self.resource_uri()
```

```{caption="{#code:sandman2:get4}Sandman2: Výsledek s odkazy"}
$ curl http://127.0.0.1:5000/courses/2
{
  "begin": "08:00",
  "day": 1,
  "end": "09:30",
  "hall": "/halls/31",
  "id_course": 2,
  "notice": "NULL",
  "self": "/courses/2",
  "semester": 1,
  "shortcut": "LEZ01",
  "sport": "/sports/17",
  "teacher": "/teachers/3"
}
```

Narazil jsem na problém, že z cizího klíče sice poznám tabulku, ale ne model.
Vyřešil jsem to tak, že před přidáním modelů do aplikace je registruji do reverzního seznamu podle tabulek,
ale tento způsob se mi příliš nelíbí, sendman2 bohužel žádný vlastní způsob nenabízí.

OAuth
-----

TODO
