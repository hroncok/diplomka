% Frameworky pro RESTful API {#frameworky}

V této kapitole představím sedmnáct (TODO spočítat) open-source frameworků pro tvorbu webových RESTful API v jazyce Python,
které zhodnotím na základě mnou stanovených hodnotících kritérií.


Hodnotící kritéria
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
 3. **LGPL** je kategorie, která obsahuje GNU Lesser General Public License [@LGPL] a případné další podobné licence, které v případě vhodného použití knihovny neovlivňují licenci díla. Pro potřeby použití frameworku se příliš neliší od předchozí skupiny, ale je třeba si dát pozor, jak framework použijeme, pokud bychom například kód frameworku zkopírovali přímo do kódu našeho díla, mohli bychom výslednou licenci ovlivnit.
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

Stav projektu
-------------

Oblíbenost
----------
