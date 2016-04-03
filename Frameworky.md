% Frameworky pro RESTful API {#frameworky}

V této kapitole představím sedmnáct (TODO spočítat) open-source frameworků pro tvorbu webových RESTful API v jazyce Python,
které zhodnotím na základě mnou stanovených hodnotících kritérií.


Hodnotící kritéria {#kriteria}
==================

Než se pustím do zkoumání a hodnocení jednotlivých frameworků, je třeba si stanovit hodnotící kritéria,
která mi umožní frameworky objektivně porovnávat a vybrat kandidáty pro kapitolu TODO.
Pokud to bude alespoň trochu možné, tak pro kritérium stanovím stupnici, na základě které půjde frameworky mezi sebou porovnat.

TODO reorganizovat kritéria nějak „podle důležitosti“.

Licence
-------

Abychom vůbec mohli zvažovat použití nějakého frameworku, musíme zjistit, jestli nám to jeho licence umožňuje.
V této práci se zabývám pouze open-source frameworky, takže bychom neměli narazit na zásadní problém.
Typ licence ale může zásadně ovlivnit licenci díla, ve kterém framework použijeme, proto je dobré se touto otázkou zabývat.

Licence tedy rozdělím do skupin podle typu, pořadí typu určuje stupnici od nejvolnější po nejstriktnější.

 1. **Public domain** obsahuje licence, které efektivně říkají, že si s frameworkem můžeme dělat prakticky, co chceme. Mezi takové řadím například Creative Commons CC0 [@CC0] nebo WTFPL [@WTFPL].
 2. **Permisivní** licence jsou takové, které vyžadují například uvedení textu licence a jméno autora, ale neovlivňují licenci výsledného díla. Příkladem jsou licence MIT [@MIT], BSD [@BSD2][@BSD3], ale i licence Pythonu [@python-license].
 3. **LGPL** je kategorie, která obsahuje GNU Lesser General Public License [@LGPL] a případné další podobné licence (například Mozilla Public License [@mpl2]), které v případě vhodného použití knihovny neovlivňují licenci díla. Pro potřeby použití frameworku se příliš neliší od předchozí skupiny, ale je třeba si dát pozor, jak framework použijeme, pokud bychom například kód frameworku zkopírovali přímo do kódu našeho díla, mohli bychom výslednou licenci ovlivnit.
 4. **Copyleft** licence jsou takové, které vyžadují, aby výsledné dílo v případě využití knihovny nebo frameworku převzalo jejich licenci [@copyleft]. Jako nejznámější exemplář jmenuji GNU General Public License [@GPLv3].
 5. **AGPL** je kategorie, která obsahuje GNU Affero General Public License [@AGPLv3] a případné další podobné licence, které navíc oproti předchozímu typu považují poskytování webové služby za distribuci díla a vyžadují tedy poskytnutí zdrojového kódu všem uživatelům služby.

Velikost kódu včetně závislostí
-------------------------------

Přestože dnes diskový prostor není tolik kritický, jako dříve, čím víc kódu framework a jeho
závislosti obsahují, tím více věcí se může zkomplikovat. Některé frameworky se označují za „lightweight“
a právě velikost kódové základny je jedním z faktorů, který vnímaní frameworku jako „lightweight“ může ovlivnit [@lightweight].

Měření budu provádět tak, že daný framework nainstaluji do prázdného virtualenvu[^virtualenv] a pak se podívám na celkovou jeho velikost -- ta bude určovat pořadí na stupnici.

[^virtualenv]: Virtualenv je virtuální prostředí pro jazyk Python umožňující instalovat závislosti různých projektů do oddělených míst. [@virtualenv]

Počet závislostí
----------------

Kromě samotné velikosti je třeba zkoumat, i kolik závislostí (přímých i nepřímých) daný framework má. Každá závislost představuje riziko i zranitelnost [@dependencies].
Jelikož čtenáře může zajímat počet přímých i počet nepřímých závislostí, budu uvádět vždy obě čísla.

Závislost na webovém frameworku
-------------------------------

Některé frameworky fungují samostatně, jiné vyžadují nějaký Python framework na tvorbu webových aplikací.
Některé webové frameworky slouží čistě jako vrstva pro poskytovaní obsahu přes protokol HTTP, jiné
striktně určují, jak bude webová aplikace vnitřně navržena. Škálu jsem tedy nastavil takto:

 1. **Standalone** je kategorie pro frameworky, které lze pro RESful API použít samostatně.
 2. **Lightweight** je kategorie pro frameworky, které vyžadují webový microframework, který slouží pouze jako vrstva mezi Pythonem a HTTP. Takovými microframeworky jsou třeba Werkzeug, Flask, Pyramid nebo Morepath.
 3. **MVC** je kategorie pro frameworky typu *Model-view-controller*, především Django[^django].

[^django]: Django samo sebe označuje jako MTV (*Model-template-view*) framework, prakticky se však jedná o MVC princip [@djangobook].

Podpora HATEOAS
---------------

HATEOAS, tedy *Hypermedia as the Engine of Application State*[^hateoas], je jedním ze základních stavebních kamenů REST architektury [@rest].
Díky principu HATEOAS nemusí REST klient o poskytovaném API vědět příliš mnoho informací předem, prostě se dotáže serverové REST aplikace skrze URL a všechny následující proveditelné akce jsou obsaženy v odpovědi vrácené serverem.

[^hateoas]: Hypermedia jako základ aplikačního stavu (TODO konzultovat překlad)

HATEOAS je ale pouze princip, konkrétních implementací je několik. Mezi ty nejznámější patří:

 * HAL [@hal],
 * JSON-LD [@jsonld],
 * Hydra [@hydra] (rozšíření JSON-LD),
 * JSON Schema [@jsonschema],
 * Collection+JSON [@collectionjson].

TODO Uvidím, co budou podporovat jednotlivé frameworky, a podle toho zkusím stanovit nějaká kritéria. IMHO by šlo počítat, kolik toho podporují, ale pochybuji, že budou podporovat více než jedno.

Podpora Pythonu 3
-----------------

Přestože Python 3 vyšel již v roce 2008 [@py3year], některé knihovny třetích stran jej stále ještě nepodporují [@py3ready].
Je tedy třeba se bohužel zabývat i tím, jestli framework Python 3 podporuje. Stejně tak může být pro někoho důležité,
jestli framework podporuje Python 2, například kvůli tomu, že nějaké další knihovny, které používá, Python 3 nepodporují.

Škálu jsme tedy stanovil takto:

 1. podpora obou verzí Pythonu,
 2. podpora pouze pro Python 3,
 3. podpora pouze pro Python 2.

Přístupová práva
----------------

TODO

Použitelnost
------------

TODO

Stav projektu
-------------

Pokud se rozhodujeme, jestli využít nějaký framework, mohly by nás zajímat i informace o projektu, jako například:

 * Kdo projekt tvoří, jsou to jednotlivci, firma?
 * Je projekt aktivně vyvíjen?
 * Vycházejí nové verze?
 * Reaguje se na hlášení chyb?
 * jsou přijímány úpravy od lidí mimo projekt?
 * Jak dlouho již projekt existuje?
 * Jak často vycházejí nové verze?
 * Má projekt dokumentaci? Je aktuální?
 * Používá projekt testy?

Tyto informace se velice těžce dají srovnávat pomocí škály, proto se pokusím na tyto otázky odpovědět alespoň v textu.

Oblíbenost
----------

Čím více lidí a projektů daný framework využívá, tím je větší šance, že v případě problému narazíme
na hotové řešení. Oblíbenost je subjektivní pojem a tak se špatně měří, využiji ale dva prvky, které o oblíbenosti mohou něco prozradit.

Většina zkoumaných frameworků má svůj kód zveřejněn na GitHubu (TODO všechny?), kde uživatelé mohou jednotlivé projekty zařadit mezi své oblíbené tím, že jím dají hvězdu (*star*) [@ghstars].
Počet těchto hvězd pak může mít částečnou vypovídající schopnost.

Frameworky jdou zároveň stáhnout z *Python Package Indexu*, kde lze vidět počet stažení za poslední den, týden a měsíc [@pypi]. Tyto informace jsou však často zkreslené kvůli různým automatickým nástrojům, které stahují všechny balíčky [@pypibad]. Budu uvádět jen hodnotu stažení za poslední měsíc, v době psaní tohoto textu.

\input{frameworky/Cornice}
\input{frameworky/Django-REST-framework}
\input{frameworky/Eve}
\input{frameworky/Falcon}
\input{frameworky/hug}
\input{frameworky/Flask-API}
\input{frameworky/Flask-RESTful}
\input{frameworky/Morepath}
\input{frameworky/Piston}
\input{frameworky/Pycnic}
\input{frameworky/Python-REST-API-framework}
\input{frameworky/Ramses}
\input{frameworky/RESTArt}
\input{frameworky/restless}
\input{frameworky/ripozo}
\input{frameworky/sandman}
\input{frameworky/Tastypie}

Srovnání
========

[V tabulce](#tab:srovnani@) najdete srovnání měřitelných kritérií. Jednotlivé sloupce mají zjednodušené názvy, ale jejich funkce odpovídá popisu [v části](#kriteria@). TODO pospat sloupce s více hodnotami (pokud budou).

| Framework             | druh licence  | velikost  | závislosti    | webový fr.    | Python    | GitHub    | PyPI      |
|-----------------------+---------------+-----------+---------------+---------------+-----------+-----------+-----------|
| Cornice               | LGPL          | 20 MB     | 2/9           | lightweight   | 3+2       | 270       | 10 903    |
| Django REST fr.       |               |           |               |               |           |           |           |
| Eve                   |               |           |               |               |           |           |           |
| Falcon                |               |           |               |               |           |           |           |
| hug                   |               |           |               |               |           |           |           |
| Flask API             |               |           |               |               |           |           |           |
| Flask-RESTful         |               |           |               |               |           |           |           |
| Morepath              |               |           |               |               |           |           |           |
| Piston                |               |           | TODO          |               |           |           |           |
| Pycnic                |               |           |               |               |           |           |           |
| Python REST API fr.   |               |           |               |               |           |           |           |
| Ramses                |               |           |               |               |           |           |           |
| RESTArt               |               |           |               |               |           |           |           |
| restless              |               |           |               |               |           |           |           |
| ripozo                |               |           |               |               |           |           |           |
| sandman               |               |           |               |               |           |           |           |
| Tastypie              |               |           |               |               |           |           |           |

Table: Srovnání měřitelných kritérií {#tab:srovnani}