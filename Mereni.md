% Měření odezvy {#mereni}

Pro měření jsem použil nástroj _ab_, určený pro měření odezvy HTTP serverů [@ab].
K běhu testovaných služeb jsem použil Gunicorn, HTTP server napsaný v Pythonu [@gunicorn].

U měření zaměřených na autentizaci a autorizaci jsem vynechal implementaci v sandmanu2,
jelikož ta příslušné části neobsahuje. Autentizaci jsem prováděl proti falešnému OAAS
z vlastního modulu `utvsapitoken`, který běžel na stejném počítači jako testované služby.
U ostatních měření jsem autentizaci i autorizaci vypnul, aby neovlivňovala měření.

Data byla při měření dostupná v MariaDB databázi běžící na stejném počítači jako testované služby.

HTTP server byl spuštěn s dvěma vlákny.
Měřící nástroj _ab_ službu testoval pěti tisíci požadavky, v dávkách po jednom stu, kde jedna dávka vždy probíhala současně.

Zde prezentované měření rychlosti odezvy bylo prováděno na konkrétních implementacích
popsaných v kapitole *\nameref{implementace}*.
Vzhledem k tomu, že jednotlivé měřené implementace jsou netriviální,
nelze zde prezentované výsledky v žádném případě generalizovat na celý použitý framework.

U jednotlivých měření uvádím příklad požadavku.
Pro jednotlivé implementace se tyto požadavky mohou mírně lišit, ale pro přehlednost uvádím pouze jeden.

Záznamy z měření s kompletními požadavky, výstupy a naměřenými rychlostmi jsou dostupné na přiloženém médiu.
Testovací skripty jsou také dostupné na přiloženém médiu a na adrese:

\url{https://github.com/hroncok/utvsapi-benchamrk}



Zobrazení jedné položky
=======================

Při tomto měření byl testován požadavek na jednu položku:

`GET /enrollments/25563/`

Jak můžete vidět [z grafu](#pic:item:chart), nejrychlejší je zde implementace v ripozu
a nejpomalejší v Django REST frameworku.

![Rychlost: Jedna položka{#pic:item:chart}](pdfs/item_chart)


Zobrazení seznamu položek
=========================

Při tomto měření byl testován požadavek na jednu stránku seznamu položek o délce dvacet:

`GET /enrollments/?page_size=20`

Je třeba poznamenat, že ripozo v seznamu uvádí jen odkazy na jednotlivé položky a ostatní
frameworky serializují všech dvacet objektů.
Bohužel ripozo jinou možnost nenabízí, tento test má tedy méně vypovídající hodnotu.
Proto je v grafu u ripoza hvězdička.

Jak můžete vidět [z grafu](#pic:list:chart), nejrychlejší je zde nepřekvapivě právě implementace v ripozu,
nejpomalejší pak v sandmanu2.

![Rychlost: Seznam položek{#pic:list:chart}](pdfs/list_chart)


Filtrování seznamu položek
==========================

Při tomto měření byl testován požadavek na seznam kurzů, které probíhají v pátek, a
velikost byla opět omezena na dvacet:

`GET /courses/?page_size=20&day=5`

Platí stejná poznámka jako u minulého měření -- ripozo je zde ve značné výhodě. V grafu je proto označeno hvězdičkou.

Jak můžete vidět [z grafu](#pic:filter:chart), nejrychlejší je opět implementace v ripozu,
ale již nemá takový náskok, nejpomalejší je opět implementace v sandmanu2.

![Rychlost: Filtrovaný seznam položek{#pic:filter:chart}](pdfs/filter_chart)


Jednoduchá autorizace
=====================

Při tomto měření byl testován požadavek na jednu položku z jiného zdroje než `/enrollments/`,
tedy u zdroje, kde je autorizační logika jednodušší:

`GET /courses/1/                    Authorization: Bearer ...`

Jak můžete vidět [z grafu](#pic:simple:auth:item:chart), nejrychlejší je opět implementace v ripozu (zde už _není_ zvýhodněný), nejpomalejší implementace v Django REST frameworku.

![Rychlost: Jedna položka s jednoduchou autorizací{#pic:simple:auth:item:chart}](pdfs/simple_auth_item_chart)



Komplexní autorizace
====================

Při tomto měření byl testován požadavek na jednu položku ze zdroje,
kde je autorizační logika komplexní:

`GET /enrollments/25563/            Authorization: Bearer ...`

Byly provedeny tři měření, pokaždé s jiným druhem tokenu (studentský, zaměstnanecký a „všemocný“).
Vzhledem k tomu, že se jednotlivé výsledky lišily jen o malou aditivní konstantu,
prezentuji zde průměr z těchto tří měření.

Jak můžete vidět [z grafu](#pic:god:teacher:student:auth:item:chart),
nejrychlejší je opět implementace v ripozu,
nejpomalejší pak implementace v Django REST frameworku.

![Rychlost: Jedna položka s komplexní autorizací{#pic:god:teacher:student:auth:item:chart}](pdfs/god_teacher_student_auth_item_chart)

Provedl jsem i měření pro seznam položek s komplexní autorizací:

`GET /enrollments/?page_size=20     Authorization: Bearer ...`

Zde se výsledky lišily podle toho, jestli se jednalo o studentský token či nikoliv.
[V grafu](#pic:god:teacher:auth:list:chart) je zobrazen průměr pro zaměstnanecký a všemocný token;
nejrychlejší je implementace v ripozu, která je zde opět ve velké výhodě, protože se jedná o seznam položek.
Implementace v Django REST frameworku je mírně pomalejší než implementace v Eve.

![Rychlost: Seznam položek s komplexní autorizací (nestudent){#pic:god:teacher:auth:list:chart}](pdfs/god_teacher_auth_list_chart)

[V grafu](#pic:student:auth:list:chart) jsou vidět výsledky pro studentský token.
Zde je ripozo pořád ve výhodě, ale přesto zaostává za nejrychlejším Django REST frameworkem i druhým Eve.

![Rychlost: Seznam položek s komplexní autorizací (student){#pic:student:auth:list:chart}](pdfs/student_auth_list_chart)

Vzhledem k rozdílným výsledkům pro různé druhy požadavků se zdráhám z měření vyvozovat nějaké závěry.
