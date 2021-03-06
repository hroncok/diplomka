hug (rozšíření pro Falcon) {#hug}
==========================

Cílem hugu je, aby vytváření API v Pythonu bylo co nejjednodušší.
Pomocí hugu lze vytvářet API nejen pro HTTP, ale i pro další média, například CLI aplikace. [@hugweb]

![Logo hugu [@hugpic]{#pic:hug}](images/hug)

Mezi hlavní cíle hugu patří [@huggithub]:

 * umožnit psaní tak stručného kódu Python API, jako by šlo o psanou definici,
 * framework by měl podporovat psaní srozumitelného kódu,
 * měl by být dostatečně rychlý; vývojář by neměl mít potřebu se kvůli výkonu poohlížet jinam,
 * psaní testů pro API napsaná v hugu by mělo být jednoduché a intuitivní,
 * magie by se měla odehrávat jen na jednom místě, ve frameworku, což je lepší než delegovat tento problém na uživatele,
 * být základním kamenem API nové generace, díky nejnovějším technologiím.

Kvůli poslednímu bodu je hug kompatibilní pouze s Pythonem 3
a pro webová API staví na frameworku Falcon, o kterém jsem psal [v části](#falcon) [@huggithub].

Příklad použití s využitím typové anotace dostupné od Pythonu 3.5 můžete vidět [v ukázce](#code:hug).

```{caption="{#code:hug}Příklad použití z dokumentace hugu \autocite{hugdoc}" .python}
"""First hug API (local and HTTP access)"""
import hug


@hug.get(examples='name=Timothy&age=26')
@hug.local()
def happy_birthday(name: hug.types.text, age: hug.types.number,
                   hug_timer=3):
    """Says happy birthday to a user"""
    return {'message': 'Happy {0} Birthday {1}!'.format(age, name),
            'took': float(hug_timer)}


# GET /happy_birthday?name=Timothy&age=26
{
    "took": 0,
    "message": "Happy 26 Birthday Timothy"
}

# GET /happy_birthday?name=Timothy
{
    "errors": {
        "age": "Required parameter not supplied"
    }
}

# GET /happy_birthday?name=Timothy&age=twentysix
{
    "errors": {
        "age": "Invalid whole number provided"
    }
}

```

Hug je mladý projekt, vznikl teprve v červenci roku 2015.
Více než tři tisíce hvězd na GitHubu za tak krátkou dobu ale napovídá, že půjde o projekt oblíbený;
z PyPI byl stažen za poslední měsíc více než sedmtisíckrát.
Vývoj probíhá docela rapidně, již vyšlo více než  čtyřicet verzí, průměrně tedy vychází rychleji než jednou týdně.
Na to doplácí především dokumentace, která zdaleka neobsahuje všechny možnosti hugu;
postrádá například kapitolu o autentizaci, přestože v kódu je tato funkcionalita obsažena.
Za projektem stojí jednotlivec Timothy Edmund Crosley, ale přispěla již třicítka vývojářů.

Hug je zveřejněn pod MIT licencí [@MIT]. Přímo závisí na Falconu a knihovně Requests, nepřímo tak má 4 závislosti a společně s nimi 16~545 řádků kódu.

HATEOAS
-------

Hug bohužel zatím nepodporuje žádné automatické způsoby pro prolinkování jednotlivých zdrojů,
nedostává tedy žádný bod.

Přístupová práva
----------------

Jak již bylo zmíněno výše, o přístupových právech dokumentace mlčí.
Z pohledu do kódu [@hugauth] je však patrné, že podporuje autentizaci pomocí:

 * HTTP Basic (jménem a heslem),
 * API klíče v HTTP hlavičce,
 * tokenu v HTTP hlavičce.

O autorizaci jsem však v kódu nic nenašel, proto dávám hugu pouze dva body.

Hug je moderní framework pro vytváření různých API v Pythonu.
Jeho filozofie je rozhodně zajímavá, ale v současnosti jej hodnotím jako příliš mladý a zatím stále se rozvíjející projekt.
