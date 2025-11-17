# wsgi_backend.py
# Este archivo expone la aplicación Flask para Gunicorn en el backend

from flask import Flask
from users.controllers.user_controller import user_controller
from users.models.db import db

app = Flask(__name__)
app.config.from_object('config.Config')
db.init_app(app)

# Registrando el blueprint del controlador de usuarios
app.register_blueprint(user_controller)
