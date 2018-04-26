#!/bin/sh

nohup ./bin/uwsgi --enable-threads --http-workers 10 --http 0.0.0.0:8080 -w uWSGI:application &
