% Implementace {#implementace}

V této kapitole budu zkoumat různé aspekty implementace ukázkové služby z kapitoly *\nameref{navrh}*
ve vybraných frameworcích.

Zkoumané aspekty implementací
=============================

Pro každý aspekt zhodnotím, zda danou věc framework umožňuje, nakolik je to systematické řešení,
nakolik jde o řešení pracné a nastíním ukázkou, jak k řešení dojít.
Zde nejprve čtenáře krátce seznámím s jednotlivými aspekty.

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
v RESTful API je ale žádoucí docílit toho, aby vztahy byly reprezentovány odkazem.
Příkladem je odkaz na učitele konkrétního kurzu.

Kromě toho je třeba zobrazit navigační odkazy, například u stránkování na další a předchozí stránku apod.

Úprava zobrazených dat
----------------------

Některá data se musí zobrazit jinak, než jak jsou uložena v databázi.
Příkladem je přetypování řetězců na čísla nebo zobrazení zkratky předmětu pouze v případě, kdy je nastaven patřičný příznak.

Zobrazení dat ve standardizované podobě
---------------------------------------

Některé frameworky zavádí vlastní formát dat v datových reprezentacích zdrojů.
V některých případech je ale vhodnější použít nějaký standardizovaný formát jako JSON API, HAL nebo Siren.

Použití přirozených identifikátorů
----------------------------------

Pokud to data umožňují, je vhodné k identifikaci zdroje použít přirozený identifikátor
namísto syntetických databázových identifikátorů.
Využití syntetických identifikátorů v RESTful API lze považovat za tzv. *leaky abstraction*[^leakyab] [@leakyab].
Příkladem přirozeného identifikátoru je zkratka sportu, kdy URI nemusí být `/sports/{id}`, ale může být `/sports/{shortcut}`.

[^leakyab]: Nenašel jsem vhodný překlad tohoto termínu do češtiny.

Provedl jsem analýzu poskytnutých dat a tabulka sportů je bohužel jediná, která obsahuje použitelný přirozený identifikátor.
Ostatní tabulky buď přirozený identifikátor nemají vůbec nebo není unikátní --
jednotlivé předměty v různých časech sdílí stejnou zkratku, ne všichni učitelé mají v datech osobní číslo apod.


Přístupová práva
----------------

Důležitým požadavkem jsou přístupová práva;
z hlediska autentizace i autorizace.
Příkladem je, že student může vidět jen své vlastní zápisy kurzů.

Pro autentizaci a autorizaci použiji OAuth 2.0 autorizační server (OAAS) FIT ČVUT [@oaas],
který umožňuje na základě tokenu poskytnutého klientem určit, jestli je klient autentizován a jaká má práva.
Pokud je token svázán s konkrétním uživatelem, z Usermap API [@uapi] zjistím jeho osobní číslo,
abych toto mohl porovnávat s osobními čísly učitelů a studentů v databázi ÚTVS.

Vzhledem k tomu, že komunikace s OAAS i Usermap API je na zvoleném frameworku nezávislá,
vytvořil jsem malý Python modul, který budu využívat ve všech implementacích;
jeho nejpodstatnější součást můžete vidět [v ukázce](#code:utvsapitoken).
Součástí modulu je i jednoduchý server, který simuluje OAAS a Usermap API pro účely testování.

```{caption="{#code:utvsapitoken}utvsapitoken: Získání informací o tokenu" .python}
class TokenClient:
    '''Class for making requests for tokens'''

    def __init__(self, check_token_uri=None, usermap_uri=None):
        self.turi = check_token_uri or \
            'https://auth.fit.cvut.cz/oauth/check_token'
        self.uuri = usermap_uri or \
            'https://kosapi.fit.cvut.cz/usermap/v1/people'

    @classmethod
    def _raise_if_error(cls, info, e):
        if 'error' in info:
            msg = info['error']
            if 'error_description' in info:
                msg = info['error_description']
            raise e(msg)

    def token_to_info(self, token):
        '''For given token, produces an info dict'''
        r = requests.get(self.turi, {'token': token})
        info = json.loads(r.text)
        self._raise_if_error(info, TokenInvalid)
        if info['exp'] <= time.time():
            raise TokenExpired('Token is expired')

        if 'user_name' in info:
            pnum, roles = self._extra_from_username(
                info['user_name'], token)
            if pnum is not None:
                info.update({'personal_number': pnum})
            if roles is not None:
                info.update({'roles': roles})

        return info

    def _extra_from_username(self, username, token):
        r = requests.get(
            self.uuri + '/' + username,
            headers={'Authorization': 'Bearer %s' % token})
        info = json.loads(r.text)
        self._raise_if_error(info, UsermapError)
        try:
            pnum = info['personalNumber']
        except KeyError:
            pnum = None
        try:
            roles = info['roles']
        except KeyError:
            roles = None
        return pnum, roles

```

Kompletní implementaci tohoto modulu najdete na přiloženém médiu a na adrese:

\url{https://github.com/hroncok/utvsapitoken}




Generování dokumentace
----------------------

Jednou z funkcí, kterou některé frameworky nabízejí, je generování dokumentace přímo z kódu.
Příkladem je, že u definice nějakého zdroje použiji Python *docstring* (dokumentační řetězec),
a uživatel API bude moci takto definovaný popis vidět.

Zkoumané funkce služby
======================

Kromě aspektů ve smyslu „jak lze něčeho ve frameworku dosáhnout“ budu zkoumat i tyto funkce implementovaných RESTful API:

 * stránkování,
 * filtrování,
 * řazení,
 * vyjednávání o obsahu,
 * rozcestník.

Rozcestníkem je zde myšlen kořenový zdroj, který poskytuje odkazy na jednotlivé zdroje.

Budu se zabývat tím, jestli dané funkce existují a jak je lze použít.
Pokud některá služba bude nabízet i další funkce, zde neuvedené, zmíním je samozřejmě také.

\input{implementace/DRF}
\input{implementace/Eve}
\input{implementace/ripozo}
\input{implementace/sandman2}

Souhrn
======

Žádná ze čtyř implementací se neobešla bez komplikací, neexistuje tedy žádný pomyslný vítěz.
U Django REST frameworku, Eve a ripoza se jednalo o nedostatky, které by se pravděpodobně daly, s rozumným množstvím úsilí, vyřešit
přispěním do samotných frameworků či dalších použitých knihoven.
Framework sandamn2 zaostával natolik, že jej nemohu doporučit.
