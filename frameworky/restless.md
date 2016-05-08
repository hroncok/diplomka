restless
========

Restless je miniframework pro tvorbu REST API. Podporuje Django, Flask, Pyramid, Tornado a Itty[^itty],
ale měl by fungovat s jakýmkoliv webovým frameworkem v Pythonu [@restless].

[^itty]: Itty je webový framework od autora restlessu.

Hlavní myšlenkou restlessu je udělat věci jednoduše a příliš je nekomplikovat, mezi hlavní výhody patří [@restless]:

 * malý a rychlý kód,
 * výchozí výstup v JSONu,
 * koncept RESTful,
 * podpora Pythonu 3.3+ (i staršího 2.6+),
 * flexibilita.

Restless v dokumentaci rovnou uvádí, že nebude podporovat automatickou integraci ORM, XML, autorizaci ani HATEOAS [@restless][@restlessp].
Dostává tedy u obou bodovaných kritérií nula bodů.

Za projektem stojí jednotlivec Daniel Lindsley, který je mj. autorem frameworku Tastypie, o kterém budu mluvit [v části](#tastypie@).
Dokumentace restlessu projekt Tastypie často zmiňuje a zdůrazňuje, že restless vznikl poučením se z chyb při tvorbě Tastypie.
Hlavní chybou bylo pokoušet se o vytvoření příliš „všemocného“ frameworku,
restless jde tedy opačnou cestou a většinu rozhodnutí nechává na uživateli [@restlessp].

Restless, na rozdíl od Tastypie, není vázán přímo na Django, ale webový framework si můžete zvolit.
Přímo v kódu existují třídy pro frameworky Django, Flask, Pyramid, Tornado a Itty, od kterých stačí dědit.
Pro jiný framework si takovou třídu můžete samozřejmě dopsat sami.
V případě změny frameworku by mělo stačit třídu vyměnit.
Příklad z dokumentace s použitím třídy pro Django můžete vidět [v ukázce](#code:restless).

Restless závisí pouze na knihovně six, kvůli zpětné kompatibilitě s Pythonem~2.
Instalace tak zabírá pouze čtvrt mebibajtu a obsahuje 1~140 řádek kódu, ale tato informace je zavádějící, protože restless ještě vyžaduje nějaký webový framework,
samostatně nefunguje.

```{caption="{#code:restless}Příklad použití s Djangem z dokumentace restlessu \autocite{restlessgh}" .python}
from django.contrib.auth.models import User

from restless.dj import DjangoResource
from restless.preparers import FieldsPreparer

from posts.models import Post


class PostResource(DjangoResource):
    # Controls what data is included in the serialized output.
    preparer = FieldsPreparer(fields={
        'id': 'id',
        'title': 'title',
        'author': 'user.username',
        'body': 'content',
        'posted_on': 'posted_on',
    })

    # GET /
    def list(self):
        return Post.objects.all()

    # GET /pk/
    def detail(self, pk):
        return Post.objects.get(id=pk)

    # POST /
    def create(self):
        return Post.objects.create(
            title=self.data['title'],
            user=User.objects.get(username=self.data['author']),
            content=self.data['body']
        )

    # PUT /pk/
    def update(self, pk):
        try:
            post = Post.objects.get(id=pk)
        except Post.DoesNotExist:
            post = Post()

        post.title = self.data['title']
        post.user = User.objects.get(username=self.data['author'])
        post.content = self.data['body']
        post.save()
        return post

    # DELETE /pk/
    def delete(self, pk):
        Post.objects.get(id=pk).delete()
```

Projekt vznikl v lednu 2014, autor jej aktivně vyvíjel do srpna toho roku, od té doby prakticky pouze přijímá cizí příspěvky,
kterých však není příliš mnoho, poslední byl přijat v létě 2015. Od té doby se kupí další a další, čekající na schválení, které možná nikdy nepřijde.
Zatím poslední verze, v pořadí sedmá, vyšla v srpnu 2014.
Daniel Lindsley se restlessu zjevně nevěnuje. Uživatelé však nadále hlásí chyby a snaží se přispět svým kódem.
Více než pět stovek hvězd na GitHubu u projektu, který byl aktivně vyvíjen půl roku, svědčí o tom, že měl potenciál.
