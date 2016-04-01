% Frameworky pro RESTful API {#frameworky}

V této kapitole představím sedmnáct (TODO spočítat) open-source frameworků pro tvorbu webových RESTful API v jazyce Python,
které zhodnotím na základě mnou stanovených hodnotících kritérií.


Hodnotící kritéria
==================

Než se pustím do zkoumání a hodnocení jednotlivých frameworků, je třeba si stanovit hodnotící kritéria,
která mi umožní frameworky objektivně porovnávat a vybrat kandidáty pro kapitolu TODO.
Pokud to bude alespoň trochu možné, tak pro kritérium stanovím stupnici, na základě které půjde frameworky mezi sebou porovnat.

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

