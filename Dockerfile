# Dockerfile para el servicio frontend con Nginx y SSL
FROM python:3.11-slim

# Instalar Nginx
RUN apt-get update && apt-get install -y nginx && rm -rf /var/lib/apt/lists/*

# Directorio de la app dentro del contenedor
WORKDIR /app

# Copiar requirements e instalar dependencias Python
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt flask-sqlalchemy gunicorn

# Copiar el código de la aplicación
COPY . /app

# Copiar configuración de Nginx
COPY nginx/nginx-frontend.conf /etc/nginx/nginx.conf

# Crear directorio para certificados SSL
RUN mkdir -p /etc/nginx/ssl

# Copiar certificados SSL
COPY ssl/nginx-selfsigned.crt /etc/nginx/ssl/
COPY ssl/nginx-selfsigned.key /etc/nginx/ssl/

# Exponer puertos HTTP y HTTPS
EXPOSE 80 443

# Script para iniciar Gunicorn y Nginx
COPY start-frontend.sh /app/start-frontend.sh
RUN chmod +x /app/start-frontend.sh

CMD ["/app/start-frontend.sh"]