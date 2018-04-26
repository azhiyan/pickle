#!/usr/bin/python

"""run this file using the following command
<path/to/uwsgi>/uwsgi --enable-threads --http 0.0.0.0:8080 -w WSGI:app &
"""

from core.webframework.webcontroller import app

app = app.app

if __name__ == '__main__':
    app.run()
