% Návrh API pro rozvrhová data ÚTVS ČVUT {#navrh}

Poskytnuté databázové pohledy
=============================

V MySQL databázi Ústavu tělesné výchovy a sportu ČVUT existují pohledy obsahující data pro sestavení rozvrhů.
Tyto pohledy mám k dispozici a nad nimi budu navrhovat RESTful službu.
V této části nejprve seznámím čtenáře se strukturou dat.
Informace čerpám z wiki FIT ČVUT v Praze provozované Oddělením pro rozvoj [@rozvojwiki].

Destinace
---------

Destinace pro výcvikové kurzy (vícedenní kurzy mimo areál školy).
Struktura je znázorněna [v tabulce](#tab:destination).

Table: Struktura pohledu v_destination {#tab:destination}

| Název sloupce		| Datový typ	| Popis 						|
|-------------------|---------------|-------------------------------|
| id_destination	| smallint(10)	| primární klíč					|
| name				| varchar(50)	| název 						|
| url				| varchar(250)	| URL stránky na utvs.cvut.cz 	|

Haly
----

Sportoviště ÚTVS, ve kterých probíhá výuka.
Struktura je znázorněna [v tabulce](#tab:hall).

Table: Struktura pohledu v_hall {#tab:hall}

| Název sloupce		| Datový typ	| Popis 						|
|-------------------|---------------|-------------------------------|
| id_hall			| smallint(6)	| primární klíč					|
| name				| varchar(50)	| název 						|
| url 				| varchar(250)	| URL stránky na utvs.cvut.cz 	|


Vyučující
---------

Vyučují jednotlivých kurzů ÚTVS.
Struktura je znázorněna [v tabulce](#tab:lectors).

Table: Struktura pohledu v_lectors {#tab:lectors}

| Název sloupce		| Datový typ	| Popis 						|
|-------------------|---------------|-------------------------------|
| id_lector			| tinyint(10)	| primární klíč					|
| title_before		| varchar(50)	| tituly před jménem			|
| name				| varchar(50)	| křestní jméno					|
| surname			| varchar(50)	| příjmení						|
| title_behind		| varchar(50)	| tituly za jménem				|
| pers_number		| varchar(20)	| osobní číslo (peridno v KOS)	|
| url 				| varchar(250)	| URL stránky na utvs.cvut.cz 	|


Sporty
------

Tabulka sportů, které se na ÚTVS praktikují.
Struktura je znázorněna [v tabulce](#tab:sports).

Table: Struktura pohledu v_sports {#tab:sports}

| Název sloupce		| Datový typ	| Popis 						|
|-------------------|---------------|-------------------------------|
| id_sport			| smallint(10)	| primární klíč					|
| short				| varchar(50)	| kód (3znaková zkratka)		|
| sport 			| varchar(50)	| název 						|
| description		| text			| popis 						|


Zápisy studentů
---------------

V této tabulce, nepřesně nazvané jako studenti, se eviduje zápis studenta na konkrétní předmět v daném semestru.
V jednom semestru zde student může mít i více záznamů. Záznamy se po několika letech promazávají.
Struktura je znázorněna [v tabulce](#tab:students).

Semestr je ve formátu `YYYY/ZZ_S`, kde `YYYY/ZZ` značí akademický rok (např. `2012/13`) a `S` paritu semestru (1 -- zimní; 2 -- letní).

Table: Struktura pohledu v_students {#tab:students}

| Název sloupce		| Datový typ	| Popis 							|
|-------------------|---------------|-----------------------------------|
| id_student		| int(11)		| primární klíč						|
| personal_number	| int(11)		| osobní číslo (peridno v KOS)		|
| kos_kod			| varchar(20)	| kód zapsaného předmětu TV v KOS 	|
| utvs				| int(11)		| ID zapsaného předmětu ÚTVS		|
| 					| 				| (v_subjects.id_subjects)			|
| semester			| varchar(10)	| semestr zápisu					|
| registration_date	| timestamp		| ?	TODO							|
| tour				| int(0)		| příznak udávající, zda je zapsaný	|
| 					| 				| předmět kurz						|
| kos_code			| int(0)		| ?	TODO							|


Předměty ÚTVS
-------------

Předmětem je zde myšlena konkrétní instance vyučovaného sportu, v daný den a hodinu.
Pokud bychom chtěli najít paralelu se systémem KOS, tak tato entita představuje sloučenou instanci předmětu a její paralelku.
Struktura je znázorněna [v tabulce](#tab:subjects).

Všimněte si, že některé číselné údaje jsou uloženy textově. TODO ověřit

TODO vyzkoumat jak se to váže na destination, pokud to je kurz a jaké je pak datum kurzu apod.

Table: Struktura pohledu v_subjects {#tab:subjects}

| Název sloupce		| Datový typ	| Popis 								|
|-------------------|---------------|---------------------------------------|
| id_subjects		| smallint(10)	| primární klíč							|
| sport 			| varchar(10)	| ID sportu (v_sports.id_sport)			|
| shortcut			| varchar(50)	| kód ÚTVS předmětu (např. TUR01)		|
| day				| varchar(10)	| den v týdnu (1–7)						|
| begin				| varchar(10)	| čas začátku výuky	TODO formát			|
| end				| varchar(10)	| čas konce výuky	TODO formát			|
| hall 				| varchar(50)	| ID haly (v_hall.id_hall)				|
| lector 			| varchar(50)	| ID vyučujícího (v_lectors.id_lector)	|
| notice			| text			| poznámka (v HTML)						|
| semester			| tinyint(4)	| parita semestru, ve kterém se vypisuje|
| 					| 				| (1 -- zimní, 2 -- letní)				|

Diagram
-------

![Diagram poskytnutých databázových pohledů [@rozvojwiki]{#pic:diagram}](pdfs/diagram)

[Na obrázku](#pic:diagram) můžete vidět diagram vztahů.

API zdroje
==========

V této části navrhnu jednotlivé API zdroje (*resources*) a režim přístupu k nim.
Nebudu se snažit o striktní návrh, kde bych definoval přesnou podobu odpovědí; to mi umožní nechat přesnou podobu na použitém frameworku.
Jednotlivé zdroje budou odpovídat poskytnutým databázovým pohledům.

/destinations
-------------

Poskytne přístup k datům z pohledu `v_destination`. Jednotlivě pomocí primárního klíče (`/destinations/<id_destination>`) nebo hromadně.
V odpovědi budou zahrnuta všechna data [z tabulky](#tab:destination).

Data budou přístupná všem autentizovaným uživatelům.

/halls
------

Poskytne přístup k datům z pohledu `v_hall`. Jednotlivě pomocí primárního klíče (`/halls/<id_hall>`) nebo hromadně.
V odpovědi budou zahrnuta všechna data [z tabulky](#tab:hall).

Data budou přístupná všem autentizovaným uživatelům.

/teachers
---------

Poskytne přístup k datům z pohledu `v_lectors`. Jednotlivě pomocí primárního klíče (`/teachers/<id_lector>`) nebo hromadně.
K přejmenování dochází kvůli sjednocení s KOSapi, Siriem a dalšími službami.
V odpovědi budou zahrnuta všechna data [z tabulky](#tab:lectors).

 * Položka `id_lector` bude přejmenována na `id_teacher`.
 * Položka `pers_number` bude přejmenována na `personal_number`.

Data budou přístupná všem autentizovaným uživatelům.

/sports
-------

Poskytne přístup k datům z pohledu `v_sports`. Jednotlivě pomocí primárního klíče (`/sports/<id_sport>`) nebo hromadně.
V odpovědi budou zahrnuta všechna data [z tabulky](#tab:sports).

Data budou přístupná všem autentizovaným uživatelům.

/enrolments
-----------

Poskytne přístup k datům z pohledu `v_students`. Jednotlivě pomocí primárního klíče (`/enrolments/<id_student>`) nebo hromadně.
V odpovědi budou zahrnuta všechna data [z tabulky](#tab:students).

 * Položka `id_student` bude přejmenována na `id_enrolment`.
 * Položka `utvs` bude přejmenována na `subject` a bude obsahovat odkaz na daný zdroj.
 * Položka `tour` bude reprezentována jako boolean.
 * TODO neznámé položky

### Přístupová práva

 * Autentizovaným uživatelům budou zpřístupněna data o jejich osobě (osobní číslo musí odpovídat osobnímu číslu přihlášeného uživatele).
 * Autentizovaným lektorům budou zpřístupněna data o jejich kurzech (osobní číslo vyučujícího daného kurzu musí odpovídat osobnímu číslu přihlášeného uživatele).
 * Speciálním autentizovaným uživatelům budou zpřístupněna všechna data, kvůli přístupu ze služeb jako Sirius.

/subjects
---------

Poskytne přístup k datům z pohledu `v_subjects`. Jednotlivě pomocí primárního klíče (`/subjects/<id_subjects>`) nebo hromadně.
V odpovědi budou zahrnuta všechna data [z tabulky](#tab:subjects).

 * Položka `id_subjects` bude přejmenována na `id_subject`.
 * Položka `lector` bude přejmenována na `teacher`.
 * Cizí klíče budou reprezentovány odkazem na daný zdroj.
 * TODO paritu semestru jinak?

Data budou přístupná všem autentizovaným uživatelům.
