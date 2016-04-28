% Implementace {#implementace}

V této kapitole budu zkoumat různé aspekty implementace ukázkové služby z kapitoly *\nameref{navrh}*
ve vybraných frameworcích.

Zkoumané aspekty implementací
=============================

Pro každý aspekt zhodnotím, zda danou věc framework umožňuje, nakolik je to systematické řešení,
nakolik jde o řešení pracné a nastíním ukázkou, jak k řešení dojít.
Zde nejprve čtenáře krátce seznámím s jednotlivými aspekty:

Namapování dat z pohledů na zdroje
----------------------------------

Základní funkcí, kterou snad každý testovaný framework bude disponovat,
je namapování dat z databázových pohledů na jednotlivé zdroje.
Příkladem je namapování dat z pohledu `v_students` na zdroj `/enrollments`.

Přejmenování položek
--------------------

V návrhu došlo k přejmenování některých položek.
Příkladem je přejmenování položky `surname` na `last_name`.

Prolinkování zdrojů ve stylu HATEOAS
------------------------------------

Data jsou v databázi prolinkována pomocí klíčů,
v RESTful API ale chceme docílit toho, aby byly vztahy reprezentovány odkazem.
Příkladem je odkaz na učitele konkrétního kurzu.


Úprava zobrazených dat
----------------------

Některá data se musí zobrazit jinak, než jak jsou uložena v databázi.
Příkladem je přetypování řetězců na čísla nebo zobrazení zkratky předmětu pouze, pokud je opravdová.

Zobrazení dat ve standardizované podobě
---------------------------------------

Některé frameworky data zobrazují, jak to programátor zrovna vymyslel.
Ideální je ale použít nějaký standardizovaný formát jako JSON API, HAL nebo Siren.

Přístupová práva
----------------

Důležitým aspektem jsou přístupová práva.
Z hlediska autentizace i autorizace.
Příkladem je, že student může vidět jen své vlastní zápisy kurzů.

TODO vysvětlit, že se používá ten fití oauth a ukázat utvsapitoken.

Generování dokumentace
----------------------

Jednou z funkcí, kterou některé frameworky nabízejí, je generování dokumentace přímo z kódu.
Příkladem je, že u definice nějakého zdroje použiji Python *docstring* (dokumentační text),
a uživatel API bude moci takto definovaný popis vidět.

Zkoumané funkce služby
======================

Kromě aspektů ve smyslu „jak lze něčeho ve frameworku dosáhnout“ budu zkoumat i funkce implementovaných RESTful API.

Mezi tyto funkce patří:

 * stránkování,
 * filtrování,
 * řazení,
 * vyjednávání o obsahu.

Budu se zabývat tím, jestli dané funkce existují a jak je lze použít.
Pokud daná služba bude nabízet nějakou další funkci pro uživatele, zmíním ji samozřejmě také.

\input{implementace/sandman2}
