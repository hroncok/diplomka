Jak říká Zen of Python [@PEP20], měl by být jeden -- a nejlépe pouze jeden -- zřejmý způsob, jak to udělat.
V případě webových RESTful API to ale v Pythonu neplatí, existuje celá řada open-source knihoven a frameworků,
které umožňují RESTful API vytvářet. Některé fungují pouze společně s frameworky na tvorbu
webových aplikací, jako například s Flaskem nebo Djangem, jiné fungují samostatně.

V této diplomové práci se budu zabývat téměř dvacítkou těchto frameworků. V kapitole *\nameref{frameworky}* je zhodnotím z hlediska
použitelnosti, množství nabízených funkcí, podpory standardů, množství závislostí, ale i z hlediska stavu a oblíbenosti projektu.

Abych mohl frameworky zkoumat více do hloubky a porovnat je i z hlediska rychlosti, navrhnu ukázkovou službu poskytující RESTful API
pro přístup k rozvrhovým datům Ústavu tělesné výchovy a sportu, ČVUT v Praze. Návrhem se budu zabývat v kapitole *\nameref{navrh}*.

Tuto službu pak implementuji ve čtyřech vybraných frameworcích na základě předchozího zkoumání a hodnocení;
o tom prozradí více kapitola *\nameref{implementace}*. Hotová řešení pak podrobím testování doby odezvy v kapitole *\nameref{mereni}*.
