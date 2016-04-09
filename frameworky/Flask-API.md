Flask API
=========

Flask API je implementace stejných webově procházetelných API,
které poskytuje Django REST framework [@flaskapi] (o něm jsem psal [v části](#django-rest-framework@)),
ale bez závislosti na Djangu.

Za projektem stojí autor Django REST frameworku, Tom Christie.
Zatím se ale bohužel jedná o rozdělanou práci [@flaskapi] a zdaleka nejde o hotový projekt.
Práce na Flask API je zároveň pozastavená, kvůli závazkům z crowdfundingové kapaně ohledně Django REST frameworku [@flaskapigh].
Tom Christie se od roku 2014 (kdy projekt i vznikl) na projektu aktivně nepodílí, existují však další jednotlivci,
kteří projekt udržují a rozvíjí.

Pomocí Flask API je nyní možné webově procházet API, jak můžete vidět [na obrázku](#pic:flaskapibrowsable),
ale tvorba API zatím není příliš automatizovaná, [vizte příklad](#code:flaskapi@)[^zhusteno].

[^zhusteno]: Příklad byl mírně zhuštěn za účelem lepší prezentace na straně A4.

![Flask API: Webově procházetelné API [@flaskapi]{#pic:flaskapibrowsable}](images/flask-api-browsable)

```{caption="{#code:flaskapi}Příklad použití z dokumentace Flask API \autocite{flaskapigh}" .python}
from flask import request, url_for
from flask_api import FlaskAPI, status, exceptions

app = FlaskAPI(__name__)

notes = {
    0: 'do the shopping',
    1: 'build the codez',
    2: 'paint the door',
}

def note_repr(key):
    return {
        'url': request.host_url.rstrip('/') + \
               url_for('notes_detail', key=key),
        'text': notes[key]
    }

@app.route("/", methods=['GET', 'POST'])
def notes_list():
    """List or create notes."""
    if request.method == 'POST':
        note = str(request.data.get('text', ''))
        idx = max(notes.keys()) + 1
        notes[idx] = note
        return note_repr(idx), status.HTTP_201_CREATED

    # request.method == 'GET'
    return [note_repr(idx) for idx in sorted(notes.keys())]

@app.route("/<int:key>/", methods=['GET', 'PUT', 'DELETE'])
def notes_detail(key):
    """Retrieve, update or delete note instances."""
    if request.method == 'PUT':
        note = str(request.data.get('text', ''))
        notes[key] = note
        return note_repr(key)

    elif request.method == 'DELETE':
        notes.pop(key, None)
        return '', status.HTTP_204_NO_CONTENT

    # request.method == 'GET'
    if key not in notes:
        raise exceptions.NotFound()
    return note_repr(key)

if __name__ == "__main__":
    app.run(debug=True)
```

Projekt v současnosti přímo závisí jen na frameworku Flask a tím má nepřímo pět závislostí a zabírá s nimi 6~MB místa.
Je distribuován pod BSD licencí [@BSD2] a podporuje obě verze Pythonu.

Do budoucna je plánováno [@flaskapi][@flaskapigh]:

 * autentizace, mj. pomocí session, tokenu i jménem a heslem;
 * přístupová práva;
 * zaškrcování přístupu;
 * API endpointy pomocí tříd;
 * vylepšení procházetelných API, například přidání drobečkové navigace;
 * možnost vlastního zpracování výjimek;
 * CSRF ochrana;
 * přihlašování a odhlašování přes prohlížeč v případě procházetelných API;
 * dokumentace o validaci požadavků;
 * dokumentace o prolinkovávání.

Je však otázka, kdy a jestli se tohoto dočkáme.
