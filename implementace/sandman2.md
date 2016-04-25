
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
To je v sandmanu možné pomocí konstrukce z SQLAlchemy (spodní část [ukázky](#code:sandman2:py45)).
Bohužel sandman2 s tím nepočítá a je potřeba předefinovat metodu `primary_key()`,
která vrací v sandmanu název sloupce v tabulce a ne nový název.
Dle mého názoru se jedná o chybu a její opravu jsem navrhl autorovi na GitHubu, zatím bez odezvy.
Vytvořil jsem tedy mixin, který použitým modelům tuto metodu předefinuje (vrchní část [ukázky](#code:sandman2:py45)).

```{caption="{#code:sandman2:py45}Sandman2: Přejmenování sloupců" .python}
class CustomizingMixin(Model):
    '''Mixin that fixes primary_key method'''
    def primary_key(self):
        '''Return the key of the model's primary key field'''
        return list(self.__table__.primary_key.columns)[0].key


class Courses(CustomizingMixin, db.Model):
    __tablename__ = 'v_subjects'

    id_course = db.Column('id_subjects', db.Integer, primary_key=True
                          key='id_course')
    teacher = db.Column('lector', db.Integer,
                        db.ForeignKey('v_lectors.id_lector')
                        key='teacher')
    # ...
```

Navzdory očekávání sandman2 nevytvořil odkazy podle cizích klíčů.
Zároveň některá číslená data zobrazoval jako stringy, protože tak byla uložena v databázi.
Toto jde upravit v metodě `to_dict`, která je
použita před serializací dat do JSONu.
Přidal jsem tedy upravenou variantu této metody do již vytvořeného mixinu ([ukázka](#code:sandman2:py5)).
Výsledek můžete vidět [v ukázce](#code:sandman2:get4).

```{caption="{#code:sandman2:py5}Sandman2: Přidání prolinkování a další úpravy" .python}
def to_dict(self):
    '''Return the resource as a dictionary'''
    result_dict = {}
    for column in self.__table__.columns:
        name = column.key
        value = result_dict[name] = getattr(self, name, None)
        try:
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
        except (TypeError, ValueError):
            pass  # data header won't pass
        result_dict['self'] = self.resource_uri()
    return result_dict
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

TODO (možná?)

Závěr
-----

Pokud máte kontrolu nad databází, nabízí sandman2 jednoduchý automatický způsob, jak vytvořit API alespoň částečně ve stylu REST.
Pokud však potřebujete data prezentovat trochu jiným způsobem, začne sandman2 házet pomyslné klacky pod nohy a základní výhoda
-- tedy automatické vytvoření API --
přestane hrát velkou roli.

Kompletní implementaci pro rozvrhová data ÚTVS ČVUT najdete na přiloženém médiu a na adrese
\url{https://github.com/hroncok/utvsapi-sandman}.
