#!/bin/bash

# Iniciar Gunicorn en segundo plano en puerto 8080
gunicorn --bind 127.0.0.1:8080 --workers 2 --threads 4 web.views:app &

# Esperar un momento para que Gunicorn inicie
sleep 2

# Iniciar Nginx en primer plano
nginx -g 'daemon off;'
