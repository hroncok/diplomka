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
