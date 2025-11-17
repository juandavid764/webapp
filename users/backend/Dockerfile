# Dockerfile para el servicio backend (API REST de usuarios) basado en Flask + Gunicorn
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*


COPY users/backend/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

# Copiar todo el proyecto
COPY . /app

EXPOSE 8000

ENV FLASK_ENV=production

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "users.backend.wsgi_backend:app", "--workers", "3", "--threads", "2", "--timeout", "120"]
