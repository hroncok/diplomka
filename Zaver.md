Open-source knihoven a frameworků pro Python, které umožňují vytvářet RESTful API, je opravdu mnoho.
V této práci jsem prozkoumal osmnáct takových frameworků, v kapitole *\nameref{frameworky}*.
Zkoumal jsem především úroveň podpory HATEOAS a řízení přístupových práv.

Na základě stanovených kritérií jsem vybral čtyři frameworky, ve kterých jsem implementoval ukázkovou službu pro účely podrobnějšího zkoumání.

Návrhem ukázkové služby jsem se zabýval v kapitole *\nameref{navrh}*.

Různé aspekty implementace REST služby ve frameworcích Django REST framework, Eve, ripozo a sandman2
jsem popsal v kapitole *\nameref{implementace}*.

Implementované služby jsem podrobil testování rychlosti v kapitole *\nameref{mereni}*.
Z měření nevzešel jasný vítěz.

### Možnosti dalšího rozvoje

Některé zkoumané frameworky trpěly nedostatky, které by v budoucnu bylo možné
ve spolupráci s autory těchto frameworků opravit.

Zkoumaný framework ripozo umožňuje napojení na různé webové frameworky,
bylo by proto zajímavé naprogramovat napojení na nějaký zatím nepodporovaný rychlý webový framework,
jako například Falcon.
