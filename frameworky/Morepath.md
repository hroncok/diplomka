Morepath
========

![Koncept loga Morepathu [@morepathpic]{#pic:morepath}](images/morepath)

Morepath je webový mikroframework podobně jako Flask nebo Bottle [@morepath].
Nepatří tak úplně mezi frameworky na vytváření RESTových API, zařadil jsem jej proto,
že přímo v sobě obsahuje součásti pro jejich tvorbu [@morepathrest].
Na rozdíl od jiných mikroframeworků je modelově orientovaný [@morepath].

Projekt vznikl v roce 2013, ale jeho historie sahá dále do minulosti [@morepathhistory].
Od roku 2013 vyšlo téměř dvacet verzí, poslední tři dny před psaním tohoto textu.
Morepath přímo závisí na čtyřech a nepřímo na pěti modulech a má s nimi 9~156 řádků kódu.
Je distribuován pod BSD licencí [@BSD3].
Autorem projektu je Martijn Faassen z firmy CONTACT Software, přispělo celkem 14 vývojářů.
226 hvězd na GitHubu a malý počet přispěvatelů dává tušit, že se nejedná o příliš slavný projekt,
obsahuje však mnoho zajímavých funkcí [@morepathsp].

V případě RESTu jde hlavně o jednoduché prolinkování v duchu HATEOAS, které můžete vidět [v ukázce](#code:morepath).
Komplexnější příklad dokumentace neobsahuje.
Morepath dostává za HATEOAS dva body.

Za účelem vytvoření webové služby je potřeba použít modely;
to mohou být v Morepathu objekty v paměti, abstrakce databázových tabulek pomocí ORM, či data uložená v NoSQL databázi.


```{caption="{#code:morepath}Příklad použití z dokumentace Morepathu \autocite{morepathrest}" .python}
@App.json(model=DocumentCollection)
def collection_default(self, request):
    return {
       'type': 'document_collection',
       'documents': [dict(id=doc.id, link=request.link(doc))
                     for doc in self.documents],
       'add': request.link(documents, 'add')
    }
```

Přístupová práva umí Morepath nastavovat na úrovni modelů či pohledů a autentizace uživatele může proběhnout na základě session [@morepathauth].
O žádných speciálních metodách autentizace v případě API se dokumentace nezmiňuje, dostává tedy jeden bod.

Hodnotím Morepath jako zajímavý webový mikroframewrok, pokud uživatel touží po modelech, ale nechce použít „velký“ MVC framework jako Django.
Poskytnutím mechanismů pro tvorbu RESTful API přímo v základu frameworku se řadí mezi ojedinělé Python webové frameworky.
