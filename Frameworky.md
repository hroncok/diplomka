% Frameworky pro RESTful API {#frameworky}

V této kapitole představím osmnáct open-source frameworků pro tvorbu webových RESTful API v jazyce Python,
které zhodnotím na základě mnou stanovených hodnotících kritérií.


Hodnotící kritéria {#kriteria}
==================

Než začnu zkoumání a hodnocení jednotlivých frameworků, je třeba si stanovit hodnotící kritéria,
která mi umožní frameworky objektivně porovnávat a vybrat kandidáty pro kapitolu *\nameref{implementace}*.
Pokud to bude alespoň trochu možné, tak pro kritérium stanovím stupnici, na základě které bude možné frameworky mezi sebou porovnat.

Licence
-------

Abychom vůbec mohli zvažovat použití některého frameworku, musíme zjistit, jestli nám to jeho licence umožňuje.
V této práci se zabývám pouze open-source frameworky, takže bychom neměli narazit na zásadní problém.
Typ licence ale může výrazně ovlivnit licenci díla, ve kterém framework použijeme, proto je dobré se touto otázkou zabývat.

Licence tedy rozdělím do skupin podle typu, pořadí typu v seznamu určuje stupnici od nejvolnější po nejstriktnější.

 1. **Public domain** zahrnuje licence, které říkají, že si s frameworkem prakticky můžeme dělat, co chceme. Mezi takové řadím například Creative Commons CC0 [@CC0] nebo WTFPL [@WTFPL].
 2. **Permisivní** licence jsou takové, které vyžadují například uvedení textu licence a jméno autora, ale neovlivňují licenci výsledného díla. Příkladem jsou licence MIT [@MIT], BSD [@BSD2][@BSD3], ale i licence Pythonu [@python-license].
 3. **LGPL** je kategorie, která obsahuje GNU Lesser General Public License [@LGPL] a další podobné licence (například Mozilla Public License [@mpl2]), které v případě vhodného použití knihovny neovlivňují licenci díla. Pro potřeby použití frameworku se příliš neliší od předchozí skupiny, ale je třeba si dát pozor, jak framework použijeme; pokud bychom například kód z frameworku zkopírovali přímo do kódu našeho díla, mohli bychom výslednou licenci ovlivnit.
 4. **Copyleft** licence jsou takové, které vyžadují, aby výsledné dílo v případě využití knihovny nebo frameworku převzalo jejich licenci [@copyleft]. Jako nejznámější exemplář jmenuji GNU General Public License [@GPLv3].
 5. **AGPL** je kategorie, která obsahuje GNU Affero General Public License [@AGPLv3] a případné další podobné licence, které navíc oproti předchozímu typu považují poskytování webové služby za distribuci díla a vyžadují tedy poskytnutí zdrojového kódu všem uživatelům služby.

Závislost na webovém frameworku
-------------------------------

Některé frameworky fungují samostatně, jiné vyžadují konkrétní Python framework na tvorbu webových aplikací.
Některé webové frameworky slouží čistě jako vrstva pro poskytovaní obsahu přes protokol HTTP, jiné
striktně určují, jak bude webová aplikace vnitřně navržena. Škálu jsem tedy nastavil takto:

 1. **Standalone** je kategorie pro frameworky, které lze pro RESTful API použít samostatně.
 2. **Lightweight** je kategorie pro frameworky, které vyžadují webový microframework, který slouží pouze jako vrstva mezi Pythonem a HTTP. Takovými microframeworky jsou třeba Werkzeug [@werkzeug], Flask [@flask], Pyramid [@pyramid] nebo Morepath [@morepath].
 3. **MVC** je kategorie pro frameworky typu *Model-view-controller*, především Django[^django].

[^django]: Django samo sebe označuje jako MTV (*Model-template-view*) framework, prakticky se však jedná o MVC princip [@djangobook].

Velikost kódu včetně závislostí
-------------------------------

Přestože dnes diskový prostor není tolik kritický jako dříve, čím víc kódu framework a jeho
závislosti obsahují, tím více věcí se může zkomplikovat. Některé frameworky se označují za „lightweight“
a právě velikost kódové základny je jedním z faktorů, který vnímaní frameworku jako „lightweight“ může ovlivnit [@lightweight].

Měření budu provádět tak, že daný framework nainstaluji do prázdného _virtualenv_[^virtualenv] a pak se podívám na jeho celkovou velikost (od té odečtu velikost „prázdného“ virtualenv) -- ta bude určovat pořadí na stupnici.

[^virtualenv]: Virtualenv je virtuální prostředí pro jazyk Python umožňující instalovat závislosti různých projektů do oddělených míst. [@virtualenv]

Počet řádků kódu
----------------

Ještě důležitější než samotná velikost v MiB je počet řádek kódu --
k velkosti mohou přispívat i jiné faktory, jako soubory s překlady, obrázky, šablonami apod.
K měření použiji nástroj cloc [@cloc], budu počítat pouze řádky v jazyce Python.
Před měřením odstraním z modulů testy. Ve srovnávací tabulce budu uvádět jak počet řádků samotného frameworku, tak celého závislostního aparátu.

Počet závislostí
----------------

Kromě samotné velikosti je třeba zkoumat i kolik závislostí (přímých i nepřímých) daný framework vyžaduje. Každá závislost představuje riziko i zranitelnost [@dependencies].
Jelikož čtenáře může zajímat počet přímých i počet nepřímých závislostí, budu uvádět vždy obě čísla.


Podpora Pythonu 3
-----------------

Přestože Python 3 vyšel již v roce 2008 [@py3year], některé knihovny třetích stran jej stále ještě nepodporují [@py3ready].
Bohužel je tedy třeba se zabývat i tím, jestli framework podporuje Python 3. Stejně tak může být pro někoho důležité,
jestli framework podporuje Python 2, například kvůli tomu, že některé knihovny, které používá, Python 3 nepodporují.

Škálu jsem tedy stanovil takto:

 1. podpora obou verzí Pythonu,
 2. podpora pouze pro Python 3,
 3. podpora pouze pro Python 2.

Oblíbenost
----------

Čím více lidí a projektů daný framework využívá, tím větší je šance, že v případě problému najdeme
hotové řešení. Oblíbenost je subjektivní pojem a tak se špatně měří, využiji ale dva prvky, které o oblíbenosti mohou něco prozradit.

Většina zkoumaných frameworků má svůj kód zveřejněn na GitHubu, kde uživatelé mohou jednotlivé projekty zařadit mezi své oblíbené tím, že jím dají hvězdu (*star*) [@ghstars].
Počet těchto hvězd pak může poskytnout určitou vypovídající hodnotu.

Frameworky jsou zároveň distribuované přes *Python Package Index*, kde lze vidět počet stažení za poslední den, týden a měsíc [@pypi]. Tyto informace jsou však často zkreslené kvůli různým automatickým nástrojům, které stahují všechny balíčky [@pypibad]. Budu uvádět jen hodnotu stažení za poslední měsíc, v době psaní tohoto textu.


Podpora HATEOAS
---------------

HATEOAS, tedy *Hypermedia as the Engine of Application State*[^hateoas], je jedním ze základních stavebních kamenů REST architektury [@rest].
Díky principu HATEOAS nemusí REST klient o poskytovaném API vědět příliš mnoho informací předem. V ideálním případě mu stačí adresa kořenového zdroje a všechny další informace (adresy souvisejících zdrojů, proveditelných akcí…) zjistí dynamicky z odpovědí serveru -- obdobně jako uživatel při procházení HTML stránek.

[^hateoas]: Hypermedia jako základ aplikačního stavu

HATEOAS je ale pouze princip, konkrétních implementací existuje hned několik. Mezi ty nejznámější patří následující.

### HAL

HAL (Hypertext Application Language) je jednoduchý formát, který nabízí konzistentní způsob prolinkování zdrojů v API [@hal].
Definuje atributy `_links` a `_embedded` pro odkazy a vnořené zdroje, šablony pro odkazy na navazující zdroje a konvenci pro odkazování dokumentace.
Schéma můžete vidět [na obrázku](#pic:hal).

![Schéma zdroje ve formátu HAL [@hal]{#pic:hal}](images/hal)

### JSON-LD

JSON-LD je formát pro serializaci prolinkovaných dat [@jsonld].
Používá se mj. pro sémantický web a RDF data [@jsonldrdf], ale lze jej použít i pro REST API.
Příklad můžete vidět [v ukázce](#code:jsonld).

```{caption="{#code:jsonld}Příklad formátu JSON-LD \autocite{jsonld}" .python}
{
  "@context": "http://json-ld.org/contexts/person.jsonld",
  "@id": "http://dbpedia.org/resource/John_Lennon",
  "name": "John Lennon",
  "born": "1940-10-09",
  "spouse": "http://dbpedia.org/resource/Cynthia_Lennon"
}
```

### Hydra (rozšíření JSON-LD)

Hydra je rozšíření pro JSON-LD, které využívá speciální slovník vhodný pro webová API [@hydra].


### JSON API

JSON API je specifikace pro webová API využívající JSON [@jsonapi].
Jedná se o velmi komplexní formát, který u každého zdroje rozlišuje data, metadata, odkazy, vztahy a další prvky.


### Collection+JSON

Collection+JSON je komplexní serializační formát postavený na JSONu určený pro kolekce dat [@collectionjson].
Příklad můžete vidět [v ukázce](#code:collectionjson).

```{caption="{#code:collectionjson}Příklad formátu Collection+JSON \autocite{collectionjson}" .python}
{ "collection" :
  {
    "version" : "1.0",
    "href" : "http://example.org/friends/",
    
    "links" : [
      {"rel" : "feed", "href" : "http://example.org/friends/rss"}
    ],

    "items" : [
      {
        "href" : "http://example.org/friends/jdoe",
        "data" : [
          {"name" : "full-name", "value" : "J. Doe",
           "prompt" : "Full Name"},
          {"name" : "email", "value" : "jdoe@example.org",
           "prompt" : "Email"}
        ],
        "links" : [
          {"rel" : "blog", "href" : "http://examples.org/blogs/jdoe",
          "prompt" : "Blog"},
          {"rel" : "avatar",
           "href" : "http://examples.org/images/jdoe",
           "prompt" : "Avatar", "render" : "image"}
        ]
      }
    ],

    "queries" : [
      {"rel" : "search", "href" : "http://example.org/friends/search",
       "prompt" : "Search",
        "data" : [
          {"name" : "search", "value" : ""}
        ]
      }
    ],

    "template" : {
      "data" : [
        {"name" : "full-name", "value" : "", "prompt" : "Full Name"},
        {"name" : "email", "value" : "", "prompt" : "Email"},
        {"name" : "blog", "value" : "", "prompt" : "Blog"},
        {"name" : "avatar", "value" : "", "prompt" : "Avatar"}
      ]
    }
  }
}
```

### Siren

Siren je specifikace pro reprezentaci entit pomocí hypermédií [@siren].
Příklad můžete vidět [v ukázce](#code:siren).

```{caption="{#code:siren}Příklad formátu Siren \autocite{siren}" .python}
{
  "class": [ "order" ],
  "properties": {
      "orderNumber": 42,
      "itemCount": 3,
      "status": "pending"
  },
  "entities": [
    {
      "class": [ "items", "collection" ],
      "rel": [ "http://x.io/rels/order-items" ],
      "href": "http://api.x.io/orders/42/items"
    },
    {
      "class": [ "info", "customer" ],
      "rel": [ "http://x.io/rels/customer" ],
      "properties": {
        "customerId": "pj123",
        "name": "Peter Joseph"
      },
      "links": [
        { "rel": [ "self" ],
          "href": "http://api.x.io/customers/pj123" }
      ]
    }
  ],
  "actions": [
    {
      "name": "add-item",
      "title": "Add Item",
      "method": "POST",
      "href": "http://api.x.io/orders/42/items",
      "type": "application/x-www-form-urlencoded",
      "fields": [
        { "name": "orderNumber", "type": "hidden", "value": "42" },
        { "name": "productCode", "type": "text" },
        { "name": "quantity", "type": "number" }
      ]
    }
  ],
  "links": [
    { "rel": [ "self" ], "href": "http://api.x.io/orders/42" },
    { "rel": [ "previous" ], "href": "http://api.x.io/orders/41" },
    { "rel": [ "next" ], "href": "http://api.x.io/orders/43" }
  ]
}
```


Vzhledem ke komplexitě možných případů nestanovuji škálu pevně,
ale na základě vlastního textového hodnocení ohodnotím každý framework nula až třemi body.

Přístupová práva
----------------

Některé frameworky přístupová práva vůbec neřeší, jiné podporují jen autentizaci,
ale ne různá práva pro různé klienty a různé zdroje,
další obsahují mechanismy a postupy, jak autentizaci a autorizaci řešit.
Některé dokonce obsahují předpřipravená řešení pro nejčastější případy,
jako je HTTP autentizace uživatelským jménem a heslem nebo OAuth.

Vzhledem ke komplexitě možných případů nestanovuji škálu pevně,
ale na základě vlastního textového hodnocení ohodnotím každý framework nula až třemi body.

Použitelnost
------------

Jak je framework použitelný a přívětivý pro programátora se velice špatně stanovuje.
Jedná se víceméně o subjektivní pojem; to, co jeden programátor považuje za přívětivé,
jiný může považovat za příliš složité.

Místo vynášení soudů o použitelnosti, založených čistě na mém osobním názoru,
nabídnu u každého frameworku ukázku z dokumentace,
aby čtenář mohl použitelnost sám posoudit.

Jednotlivé ukázky se liší délkou i účelem.
Ukázky z vybraných frameworků sloužící ke stejnému účelu najdete v kapitole *\nameref{implementace}*.

Stav projektu
-------------

Pokud se rozhodujeme, jestli využít nějaký framework, mohly by nás zajímat i informace o projektu, jako například:

 * Kdo projekt tvoří; jsou to jednotlivci, firma?
 * Je projekt aktivně vyvíjen?
 * Vycházejí nové verze?
 * Reaguje někdo na hlášené chyby?
 * Jsou přijímány úpravy od lidí mimo projekt?
 * Jak dlouho již projekt existuje?
 * Jak často vycházejí nové verze?
 * Má projekt dokumentaci? Je aktuální?

Tyto informace se dají jen velice těžko srovnávat pomocí číselné škály, proto se pokusím na tyto otázky odpovědět alespoň textově.

\input{frameworky/Cornice}
\input{frameworky/Django-REST-framework}
\input{frameworky/Eve}
\input{frameworky/Falcon}
\input{frameworky/hug}
\input{frameworky/Flask-API}
\input{frameworky/Flask-RESTful}
\input{frameworky/Morepath}
\input{frameworky/Nefertari}
\input{frameworky/Ramses}
\input{frameworky/Piston}
\input{frameworky/Pycnic}
\input{frameworky/Python-REST-API-framework}
\input{frameworky/RESTArt}
\input{frameworky/restless}
\input{frameworky/ripozo}
\input{frameworky/sandman}
\input{frameworky/Tastypie}

Srovnání
========

[V tabulce](#tab:body) najdete udělené body za podporu HATEOASu a řízení přístupových práv.

| Framework             | HATEOAS                               | Přístupová práva                      |
|-----------------------+---------------------------------------+---------------------------------------|
| Cornice               |                                       | \textbullet                           |
| Django REST fr.       | \textbullet \textbullet \textbullet   | \textbullet \textbullet \textbullet   |
| Eve                   | \textbullet \textbullet \textbullet   | \textbullet \textbullet \textbullet   |
| Falcon                |                                       |                                       |
| hug                   |                                       | \textbullet \textbullet               |
| Flask API             |                                       |                                       |
| Flask-RESTful         |                                       |                                       |
| Morepath              | \textbullet \textbullet               | \textbullet                           |
| Nefertari             |                                       | \textbullet                           |
| Ramses                |                                       | \textbullet                           |
| Piston                |                                       | \textbullet \textbullet \textbullet   |
| Pycnic                |                                       |                                       |
| Python REST API fr.   | \textbullet                           | \textbullet \textbullet               |
| RESTArt               | \textbullet                           | \textbullet                           |
| restless              |                                       |                                       |
| ripozo                | \textbullet \textbullet \textbullet   | \textbullet \textbullet               |
| sandman2              | \textbullet \textbullet               |                                       |
| Tastypie              | \textbullet \textbullet \textbullet   | \textbullet \textbullet \textbullet   |

Table: Bodové ohodnocení {#tab:body}

[V tabulce](#tab:srovnani) najdete srovnání měřitelných kritérií. Jednotlivé sloupce mají zjednodušené názvy, ale jejich funkce odpovídá popisu [v části](#kriteria@).
Tučně jsou označeny hodnoty, které v daném sloupci dominují.

[V tabulce](#tab:informace) pak najdete informační přehled o zkoumaných frameworcích: webový framework, URL domovské stránky a číslo zkoumané verze.

| Framework             | druh licence  | webový fr.        |           MiB |     řádky |     ř. včetně |   závisl.     |   Py  |    GitHub |          PyPI |
|-----------------------+---------------+-------------------+---------------+-----------+---------------+---------------+-------+-----------+---------------|
| Cornice               | LGPL          | lightweight       |            12 |     1 198 |        24 625 |           2/9 |**3+2**|       270 |        10 903 |
| Django REST fr.       | **permisivní**| MVC               |            43 |     7 057 |        79 854 |           1/1 |**3+2**| **5 606** |   **316 772** |
| Eve                   | **permisivní**| lightweight       |            10 |     3 440 |        35 009 |         10/10 |**3+2**|     3 121 |         7 480 |
| Falcon                | **permisivní**| **standalone**    |           0,9 |     2 352 |         3 034 |           2/2 |**3+2**|     2 756 |        51 071 |
| hug                   | **permisivní**| lightweight       |             4 |     2 367 |        16 545 |           2/4 |     3 |     3 020 |         7 674 |
| Flask API             | **permisivní**| lightweight       |             6 |       620 |        20 938 |           1/5 |**3+2**|       688 |         7 594 |
| Flask-RESTful         | **permisivní**| lightweight       |             9 |       967 |        27 718 |           4/9 |**3+2**|     1 920 |       172 775 |
| Morepath              | **permisivní**| **standalone**    |             4 |     1 940 |         9 156 |           4/5 |**3+2**|       226 |         1 594 |
| Nefertari             | **permisivní**| lightweight       |            16 |     2 905 |        54 339 |          9/18 |**3+2**|        37 |           812 |
| Ramses                | **permisivní**| lightweight       |            19 |     1 067 |        68 594 |          7/29 |**3+2**|       216 |           661 |
| Piston                | **permisivní**| MVC               |            49 |     1 935 |        75 311 |           1/1 |     2 |        -- |         2 419 |
| Pycnic                | **permisivní**| **standalone**    |      **0,08** |   **226** |       **226** |       **0/0** |**3+2**|        33 |           304 |
| Python REST API fr.   | **permisivní**| lightweight       |             3 |       954 |        15 988 |           2/3 |     2 |         4 |           248 |
| RESTArt               | **permisivní**| lightweight       |             3 |       798 |        20 105 |           4/5 |**3+2**|        10 |           829 |
| restless              | **permisivní**| lightw./MVC       |   $\geq$ 0,25 |       528 |  $\geq$ 1 140 |    $\geq$ 1/1 |**3+2**|       520 |         7 909 |
| ripozo                | copyleft      | lightw./MVC       |    $\geq$ 0,5 |     1 518 |  $\geq$ 2 130 |    $\geq$ 1/1 |**3+2**|       151 |         2 411 |
| sandman2              | **permisivní**| lightweight       |            23 |       446 |        82 207 |          4/12 |**3+2**|       128 |           625 |
| Tastypie              | **permisivní**| MVC               |            41 |     3 292 |        80 139 |           3/4 |**3+2**|     2 940 |        28 966 |

Table: Srovnání měřitelných kritérií {#tab:srovnani}




| Framework             | webový fr.    | webová stránka                                        | zk. verze |
|-----------------------+---------------+-------------------------------------------------------+-----------|
| Cornice               | Pyramid       | \url{https://cornice.readthedocs.org/}                | 1.2.1     |
| Django REST fr.       | Django        | \url{http://www.django-rest-framework.org/}           | 3.3.3     |
| Eve                   | Flask         | \url{http://python-eve.org/}                          | 0.6.3     |
| Falcon                | --            | \url{http://falconframework.org/}                     | 0.3.0     |
| hug                   | Falcon        | \url{http://www.hug.rest/}                            | 2.0.6     |
| Flask API             | Flask         | \url{http://www.flaskapi.org/}                        | 0.6.5     |
| Flask-RESTful         | Flask         | \url{https://flask-restful.readthedocs.org/}          | 0.3.5     |
| Morepath              | --            | \url{https://morepath.readthedocs.org/}               | 0.13      |
| Nefertari             | Pyramid       | \url{https://nefertari.readthedocs.org/}              | 0.6.1     |
| Ramses                | Pyramid       | \url{http://ramses.tech/}                             | 0.5.1     |
| Piston                | Django        | \url{https://bitbucket.org/jespern/django-piston/}    | 0.2.3     |
| Pycnic                | --            | \url{http://pycnic.nullism.com/}                      | 0.0.5     |
| Python REST API fr.   | Werkzeug      | \url{https://python-rest-framework.readthedocs.org/}  | 1.3       |
| RESTArt               | Werkzeug      | \url{https://restart.readthedocs.org/}                | 0.1.3     |
| restless              | *volitelný*   | \url{https://restless.readthedocs.org/}               | 2.0.1     |
| ripozo                | *volitelný*   | \url{https://ripozo.readthedocs.org/}                 | 1.3.0     |
| sandman2              | Flask         | \url{http://pythonhosted.org/sandman2/}               | 0.0.7     |
| Tastypie              | Django        | \url{http://tastypieapi.org/}                         | 0.13.3    |

Table: Informace o frameworcích {#tab:informace}

Pro implementaci si vybírám frameworky Eve a ripozo, na základě vysokého hodnocení v oblasti HATEOAS i přístupových práv.

Vysoké hodnocení získaly i Django REST framework a Tastypie, ale jelikož jsou oba frameworky pro Django a implementace by byla příliš podobná,
vybírám si k implementaci pouze Django REST framework, který je podle indikátorů ze všech zkoumaných frameworků nejoblíbenější.

Navíc si vybírám sandman2, který nemá tak dobré hodnocení,
ale slibuje automatické vytvoření API.
Rád bych ze stejného důvodu zkoumal i Ramses, ale ten není možné použít s daty v MySQL databázi.
