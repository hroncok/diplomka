Pycnic
======

![Logo Pycnicu [@pycnicpic]{#pic:pycnic}](images/pycnic)

```{caption="{#code:pycnic}Příklad použití z dokumentace Pycnicu \autocite{pycnicpost}" .python}
from pycnic.core import Handler, WSGI
from pycnic.errors import HTTP_400

class UsersHandler(Handler):

    def post(self):

        if not self.request.data.get("username"):
            raise HTTP_400("Yo dawg, you need to provide a username")

        return {
            "username":self.request.data["username"],
            "authID":self.request.cookies.get("auth_id"),
            "yourIp":self.request.ip,
            "rawBody":self.request.body,
            "method":self.request.method,
            "json":self.request.data,
            "XForward":self.request.environ["HTTP_X_FORWARDED_FOR"]
        }

class app(WSGI):
    routes = [ ("/user", UserHandler()) ]
```