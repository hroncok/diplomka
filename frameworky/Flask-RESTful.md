Flask-RESTful
=============

![Logo Flask-RESTful [@flaskresfulpic]{#pic:flaskresful}](images/flask-restful)

Flask-RESTful je rozšíření Flasku, které přidává podporu pro rychlé vytváření RESTových API.
Jedná se o tenkou vrstvu abstrakce, která by měla fungovat s existujícím ORM a dalšími knihovnami.
Flask-RESTful je navržen tak, aby ho uživatelé obeznámení s Flaskem co nejrychleji pochopili. [@flaskresful]

Za vývojem Flask-RESTful stojí firma Twilio, ale přispělo do něj více než sto jednotlivců.
Je zveřejněn pod BSD licencí [@BSD3].
Závisí na Flasku a dalších třech modulech. Celkově tak nepřímo závisí na modulech devíti a společně s nimi má 27~718 řádků kódu.
Na GitHubu má necelé dva tisíce hvězd a na PyPI má za poslední měsíc více než 170 tisíc stažení.
Podporuje obě verze Pythonu.
Projekt vznikl v roce 2012, od té doby vyšlo 27 verzí, poslední v prosinci roku 2015.

Příklad použití můžete vidět [v ukázce](#code:flaskresful)[^zhusteno].

[^zhusteno]: Příklad byl mírně zhuštěn za účelem lepší prezentace na straně formátu A4.

```{caption="{#code:flaskresful}Příklad použití z dokumentace Flask-RESTful \autocite{flaskrestfuldoc}" .python}
from flask import Flask
from flask_restful import reqparse, abort, Api, Resource

app = Flask(__name__)
api = Api(app)

TODOS = {'todo1': {'task': 'build an API'}, ...}

def abort_if_todo_doesnt_exist(todo_id):
    if todo_id not in TODOS:
        abort(404, message="Todo {} doesn't exist".format(todo_id))

parser = reqparse.RequestParser()
parser.add_argument('task')

# shows a single todo item and lets you delete a todo item
class Todo(Resource):
    def get(self, todo_id):
        abort_if_todo_doesnt_exist(todo_id)
        return TODOS[todo_id]

    def delete(self, todo_id):
        abort_if_todo_doesnt_exist(todo_id)
        del TODOS[todo_id]
        return '', 204

    def put(self, todo_id):
        args = parser.parse_args()
        task = {'task': args['task']}
        TODOS[todo_id] = task
        return task, 201

# shows a list of all todos, and lets you POST to add new tasks
class TodoList(Resource):
    def get(self):
        return TODOS

    def post(self):
        args = parser.parse_args()
        todo_id = int(max(TODOS.keys()).lstrip('todo')) + 1
        todo_id = 'todo%i' % todo_id
        TODOS[todo_id] = {'task': args['task']}
        return TODOS[todo_id], 201

# Actually setup the Api resource routing here
api.add_resource(TodoList, '/todos')
api.add_resource(Todo, '/todos/<todo_id>')

if __name__ == '__main__':
    app.run(debug=True)
```

Flask-RESTful je nízkoúrovňový framework, který zjednodušuje tvorbu REST API oproti použití čistého Flasku,
ale nepřináší žádné pokročilé funkce jako podporu autentizace a autorizace, či prolinkování a HATEOAS. Nedostává tedy žádné body.
Ze zajímavých funkcí Flask-RESTful mohu jmenovat vyjednávání o obsahu či podporu *blueprintů* (koncept z Flasku [@blueprint]).
