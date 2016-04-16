RESTArt
=======

TODO

```{caption="{#code:restart}Příklad použití z dokumentace RESTArtu \autocite{restartqs}" .python}
from restart.api import RESTArt
from restart.resource import Resource

api = RESTArt()

@api.route(methods=['GET'])
class Greeting(Resource):
    name = 'greeting'

    def read(self, request):
        return {'hello': 'world'}
```