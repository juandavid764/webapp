# Sistema de Gestión de Usuarios - Flask Web Application

![Python](https://img.shields.io/badge/Python-3.11-blue.svg)
![Flask](https://img.shields.io/badge/Flask-2.2+-green.svg)
![MySQL](https://img.shields.io/badge/MySQL-8.0-orange.svg)
![Docker](https://img.shields.io/badge/Docker-Compose-blue.svg)
![License](https://img.shields.io/badge/License-Practice-yellow.svg)

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características](#-características)
- [Arquitectura](#-arquitectura)
- [Tecnologías](#-tecnologías)
- [Requisitos Previos](#-requisitos-previos)
- [Instalación y Configuración](#-instalación-y-configuración)
- [Uso](#-uso)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [API REST](#-api-rest)
- [Base de Datos](#-base-de-datos)
- [Seguridad HTTPS](#-seguridad-https)
- [Docker](#-docker)
- [Desarrollo](#-desarrollo)


## 📖 Descripción

Sistema web completo de gestión de usuarios (CRUD) desarrollado con Flask, utilizando arquitectura de microservicios con Docker. La aplicación implementa separación entre frontend y backend, con base de datos MySQL y servidor Nginx configurado con HTTPS.

## ✨ Características

### Características Técnicas
- Separación de responsabilidades (Frontend/Backend/Database)
- Patron MVC (Model-View-Controller)
- Gunicorn como servidor WSGI de producción
- Health checks para servicios de base de datos
- Volúmenes Docker para persistencia de datos
- Redirección automática HTTP → HTTPS

## 🏗️ Arquitectura

### Diagrama de Servicios

```
┌─────────────────────────────────────────────────────────────┐
│                         CLIENTE                              │
│                      (Navegador Web)                         │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTPS (443) / HTTP (80)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   FRONTEND CONTAINER                         │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              NGINX (Reverse Proxy)                     │ │
│  │  • SSL/TLS Termination                                 │ │
│  │  • HTTP → HTTPS Redirect                               │ │
│  │  • Routing: /api/* → Backend                          │ │
│  │  •          /*     → Frontend App                     │ │
│  └──────────┬───────────────────────┬─────────────────────┘ │
│             │                       │                        │
│             ▼                       ▼                        │
│  ┌─────────────────────┐  ┌─────────────────────────────┐  │
│  │   Gunicorn:8080     │  │   Backend API:5001          │  │
│  │   (Flask App)       │  │   (via host.docker.internal)│  │
│  │   • Templates       │  │                              │  │
│  │   • Static Files    │  │                              │  │
│  └─────────────────────┘  └──────────────┬───────────────┘  │
└───────────────────────────────────────────┼──────────────────┘
                                            │
                         ┌──────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                   BACKEND CONTAINER                          │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Gunicorn:8000                             │ │
│  │              (Flask REST API)                          │ │
│  │  • User Controller (CRUD Endpoints)                   │ │
│  │  • SQLAlchemy ORM                                     │ │
│  │  • CORS Enabled                                       │ │
│  └──────────────────────────┬─────────────────────────────┘ │
└─────────────────────────────┼────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   DATABASE CONTAINER                         │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              MySQL 8.0:3306                            │ │
│  │  • Database: myflaskapp                               │ │
│  │  • Table: users                                       │ │
│  │  • Volume: db_data (persistent)                       │ │
│  │  • Healthcheck Enabled                                │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```


## 🛠️ Tecnologías

### Backend
- **Python 3.11** - Lenguaje de programación
- **Flask 2.2+** - Framework web
- **SQLAlchemy 1.4+** - ORM (Object-Relational Mapping)
- **Flask-SQLAlchemy** - Integración SQLAlchemy con Flask
- **PyMySQL 1.0+** - Driver MySQL para Python
- **Flask-CORS 3.0+** - Manejo de CORS
- **Gunicorn 20.0+** - Servidor WSGI para producción

### Frontend
- **HTML5** - Estructura
- **CSS3 / Bootstrap 4.5** - Estilos responsivos
- **JavaScript (Vanilla)** - Lógica cliente
- **Jinja2** - Motor de plantillas

### Infraestructura
- **MySQL 8.0** - Sistema de gestión de base de datos
- **Nginx** - Servidor web y proxy reverso
- **Docker & Docker Compose** - Contenedorización
- **OpenSSL** - Certificados SSL/TLS

## 📦 Requisitos Previos

### Software Necesario
- **Docker** (versión 20.10+)
- **Docker Compose** (versión 1.29+)
- **Git** (para clonar el repositorio)

### Puertos Requeridos
Los siguientes puertos deben estar disponibles:
- `80` - HTTP (redirige a HTTPS)
- `443` - HTTPS (aplicación web)
- `3306` - MySQL (opcional, solo para acceso externo)
- `5001` - Backend API (expuesto en host)

### Verificar Instalación
```bash
# Verificar Docker
docker --version

# Verificar Docker Compose
docker-compose --version

# Verificar puertos disponibles
sudo lsof -i :80
sudo lsof -i :443
```

## 🚀 Instalación y Configuración

### 1. Clonar el Repositorio
```bash
git clone <repository-url>
cd webapp
```

### 2. Verificar Certificados SSL
Los certificados SSL ya están incluidos en `ssl/`:
- `ssl/nginx-selfsigned.crt`
- `ssl/nginx-selfsigned.key`

Para regenerarlos (opcional):
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/nginx-selfsigned.key \
  -out ssl/nginx-selfsigned.crt \
  -subj "/C=ES/ST=Madrid/L=Madrid/O=Practice/OU=IT/CN=localhost"
```

### 3. Revisar Configuración

#### Base de Datos (`config.py`)
```python
MYSQL_HOST = 'db'
MYSQL_USER = 'miniweb_user'
MYSQL_PASSWORD = 'miniweb_pass'
MYSQL_DB = 'myflaskapp'
```

#### Docker Compose (`docker-compose.yml`)
- Puertos configurados: 80, 443, 3306, 5001
- Volumen persistente: `db_data`
- Healthcheck para MySQL habilitado

### 4. Levantar los Servicios
```bash
# Construir e iniciar todos los contenedores
docker-compose up -d

# Ver logs en tiempo real
docker-compose logs -f

# Verificar estado de los servicios
docker-compose ps
```

### 5. Verificar Instalación

#### Comprobar servicios activos:
```bash
# Listar contenedores
docker ps

# Deberías ver:
# - miniweb-frontend
# - miniweb-backend
# - miniweb-db
```

#### Probar conectividad:
```bash
# Probar frontend
curl -k https://localhost

# Probar API
curl -k https://localhost/api/users

# Verificar redirección HTTP → HTTPS
curl -I http://localhost
```

## 💻 Uso

### Acceso a la Aplicación

#### Interfaz Web
```
https://localhost
```

**Nota:** El navegador mostrará una advertencia de seguridad debido al certificado autofirmado. Esto es normal en desarrollo. Haz clic en "Avanzado" → "Continuar al sitio".

#### API REST Directa
```
https://localhost/api/users
```

### Operaciones CRUD

#### 1. Crear Usuario
En la interfaz web:
1. Completa el formulario "Add New User"
2. Haz clic en "Create User"
3. Haz clic en "Get Users" para ver el nuevo usuario

Usando cURL:
```bash
curl -k -X POST https://localhost/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "username": "juanperez",
    "password": "securepass123"
  }'
```

#### 2. Listar Usuarios
En la interfaz:
- Haz clic en el botón "Get Users"

Usando cURL:
```bash
curl -k https://localhost/api/users
```

#### 3. Editar Usuario
En la interfaz:
1. Haz clic en "Edit" junto al usuario
2. Modifica los campos necesarios
3. Haz clic en "Save Changes"

Usando cURL:
```bash
curl -k -X PUT https://localhost/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Juan Pérez Actualizado",
    "email": "juan.nuevo@example.com",
    "username": "juanperez",
    "password": "newpass456"
  }'
```

#### 4. Eliminar Usuario
En la interfaz:
- Haz clic en "Delete" y confirma la acción

Usando cURL:
```bash
curl -k -X DELETE https://localhost/api/users/1
```

#### 5. Obtener Usuario Individual
```bash
curl -k https://localhost/api/users/1
```

### Gestión de Servicios Docker

```bash
# Detener servicios
docker-compose down

# Detener y eliminar volúmenes (¡CUIDADO! Borra datos)
docker-compose down -v

# Reiniciar un servicio específico
docker-compose restart frontend

# Reconstruir servicios después de cambios
docker-compose build
docker-compose up -d

# Ver logs de un servicio específico
docker logs miniweb-frontend
docker logs miniweb-backend
docker logs miniweb-db
```

## 📁 Estructura del Proyecto

```
webapp/
├── config.py                    # Configuración de base de datos
├── docker-compose.yml           # Orquestación de servicios
├── Dockerfile                   # Imagen del frontend (Nginx + Flask)
├── requirements.txt             # Dependencias Python del frontend
├── run.py                       # Script de ejecución desarrollo
├── wsgi_frontend.py             # Entry point WSGI frontend
├── start-frontend.sh            # Script de inicio Gunicorn + Nginx
├── HTTPS_CONFIG.md              # Documentación detallada de HTTPS
├── README.md                    # Este archivo
│
├── nginx/                       # Configuraciones Nginx
│   ├── nginx-frontend.conf      # Config activa (con SSL)
│   └── nginx.conf               # Config alternativa
│
├── ssl/                         # Certificados SSL
│   ├── nginx-selfsigned.crt     # Certificado público
│   └── nginx-selfsigned.key     # Clave privada
│
├── init.sql/                    # Scripts de inicialización DB (vacío)
│
├── users/                       # Módulo de usuarios
│   ├── backend/                 # Servicio backend
│   │   ├── Dockerfile           # Imagen del backend
│   │   ├── requirements.txt     # Dependencias backend
│   │   └── wsgi_backend.py      # Entry point WSGI backend
│   │
│   ├── controllers/             # Controladores (lógica de negocio)
│   │   ├── user_controller.py   # CRUD endpoints
│   │   └── __pycache__/
│   │
│   └── models/                  # Modelos de datos
│       ├── db.py                # Instancia SQLAlchemy
│       ├── user_model.py        # Modelo User
│       └── __pycache__/
│
└── web/                         # Aplicación web frontend
    ├── views.py                 # Rutas y vistas Flask
    ├── __pycache__/
    │
    ├── static/                  # Archivos estáticos
    │   └── script.js            # JavaScript para CRUD
    │
    └── templates/               # Plantillas HTML
        ├── index.html           # Página principal
        └── edit.html            # Página de edición
```

### Descripción de Archivos Clave

#### Configuración
- **`config.py`**: Configuración centralizada de conexión a MySQL
- **`docker-compose.yml`**: Define los 3 servicios (db, backend, frontend)
- **`Dockerfile`**: Construye imagen frontend con Nginx, Gunicorn y Flask
- **`users/backend/Dockerfile`**: Construye imagen backend solo con Flask API

#### Aplicación
- **`web/views.py`**: Define rutas `/` y `/edit/<id>`, inicializa Flask y DB
- **`users/controllers/user_controller.py`**: Implementa API REST con 5 endpoints
- **`users/models/user_model.py`**: Define modelo SQLAlchemy para tabla `users`
- **`web/static/script.js`**: Funciones JavaScript para llamadas AJAX al API

#### Infraestructura
- **`nginx/nginx-frontend.conf`**: Configuración Nginx con SSL, routing a backend/frontend
- **`start-frontend.sh`**: Inicia Gunicorn en background y Nginx en foreground
- **`ssl/`**: Certificados SSL autofirmados para HTTPS

## 🔌 API REST

### Base URL
```
https://localhost/api
```

### Endpoints

#### 1. Obtener Todos los Usuarios
```http
GET /api/users
```

**Respuesta Exitosa (200 OK):**
```json
[
  {
    "id": 1,
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "username": "juanperez"
  },
  {
    "id": 2,
    "name": "María García",
    "email": "maria@example.com",
    "username": "mariagarcia"
  }
]
```

#### 2. Obtener Usuario por ID
```http
GET /api/users/{user_id}
```

**Parámetros:**
- `user_id` (int): ID del usuario

**Respuesta Exitosa (200 OK):**
```json
{
  "id": 1,
  "name": "Juan Pérez",
  "email": "juan@example.com",
  "username": "juanperez"
}
```

**Respuesta Error (404 Not Found):**
```json
{
  "error": "User not found"
}
```

#### 3. Crear Usuario
```http
POST /api/users
```

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
  "name": "Nuevo Usuario",
  "email": "nuevo@example.com",
  "username": "nuevousuario",
  "password": "password123"
}
```

**Respuesta Exitosa (201 Created):**
```json
{
  "message": "User created successfully"
}
```

#### 4. Actualizar Usuario
```http
PUT /api/users/{user_id}
```

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
  "name": "Usuario Actualizado",
  "email": "actualizado@example.com",
  "username": "useractualizado",
  "password": "newpassword456"
}
```

**Respuesta Exitosa (200 OK):**
```json
{
  "message": "User updated successfully"
}
```

#### 5. Eliminar Usuario
```http
DELETE /api/users/{user_id}
```

**Respuesta Exitosa (200 OK):**
```json
{
  "message": "User deleted successfully"
}
```

### Códigos de Estado HTTP
- `200 OK` - Operación exitosa
- `201 Created` - Recurso creado exitosamente
- `404 Not Found` - Recurso no encontrado
- `500 Internal Server Error` - Error del servidor

## 🗄️ Base de Datos

### Esquema MySQL

#### Tabla: `users`
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL
);
```

### Modelo SQLAlchemy

```python
class Users(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    username = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)
```

### Conexión a la Base de Datos

#### Desde el Host (opcional)
```bash
mysql -h 127.0.0.1 -P 3306 -u miniweb_user -pminiweb_pass myflaskapp
```

#### Desde el Contenedor
```bash
docker exec -it miniweb-db mysql -u miniweb_user -pminiweb_pass myflaskapp
```

### Comandos Útiles MySQL

```sql
-- Ver todas las tablas
SHOW TABLES;

-- Ver estructura de la tabla users
DESCRIBE users;

-- Ver todos los usuarios
SELECT * FROM users;

-- Crear usuario de prueba
INSERT INTO users (name, email, username, password)
VALUES ('Test User', 'test@example.com', 'testuser', 'testpass123');

-- Eliminar todos los usuarios (¡CUIDADO!)
TRUNCATE TABLE users;
```

### Persistencia de Datos

Los datos se almacenan en un volumen Docker llamado `db_data`:

```bash
# Listar volúmenes
docker volume ls

# Inspeccionar volumen
docker volume inspect webapp_db_data

# Eliminar volumen (¡BORRA TODOS LOS DATOS!)
docker-compose down -v
```

## 🔒 Seguridad HTTPS

### Configuración SSL/TLS

#### Certificado Autofirmado
El proyecto utiliza certificados SSL autofirmados para desarrollo:

**Ubicación:**
- Certificado: `ssl/nginx-selfsigned.crt`
- Clave privada: `ssl/nginx-selfsigned.key`

**Detalles del Certificado:**
- **Algoritmo:** RSA 2048 bits
- **Validez:** 365 días
- **Subject:** CN=localhost, O=Practice, C=ES
- **Uso:** Desarrollo/Práctica únicamente

#### Protocolos y Cifrados
```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers HIGH:!aNULL:!MD5;
ssl_prefer_server_ciphers on;
```

### Características de Seguridad

✅ **Redirección HTTP → HTTPS** automática
✅ **TLS 1.2 y 1.3** habilitados
✅ **Cifrados fuertes** configurados
✅ **Headers de seguridad** configurados en Nginx

### Verificar Certificado

```bash
# Ver información del certificado
openssl x509 -in ssl/nginx-selfsigned.crt -text -noout

# Verificar fechas de validez
openssl x509 -in ssl/nginx-selfsigned.crt -noout -dates

# Probar conexión SSL
openssl s_client -connect localhost:443 -showcerts
```

### ⚠️ Advertencias de Seguridad

**IMPORTANTE:** Este certificado es autofirmado y **SOLO debe usarse en desarrollo**.

Para producción necesitas:
1. Certificado emitido por una CA confiable (Let's Encrypt, DigiCert, etc.)
2. Dominio válido registrado
3. Configuración adicional de seguridad (HSTS, CSP, etc.)
4. Actualización regular de certificados

### Generar Nuevo Certificado

```bash
# Generar certificado autofirmado (válido 1 año)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/nginx-selfsigned.key \
  -out ssl/nginx-selfsigned.crt \
  -subj "/C=ES/ST=Madrid/L=Madrid/O=Practice/OU=IT/CN=localhost"

# Dar permisos apropiados
chmod 600 ssl/nginx-selfsigned.key
chmod 644 ssl/nginx-selfsigned.crt

# Reconstruir contenedor frontend
docker-compose build frontend
docker-compose up -d frontend
```

## 🐳 Docker

### Servicios

#### 1. Database (`db`)
```yaml
imagen: mysql:8.0
puerto: 3306
volumen: db_data
healthcheck: activo
```

**Características:**
- MySQL 8.0 oficial
- Healthcheck cada 10 segundos
- Inicialización con scripts en `init.sql/`
- Credenciales en variables de entorno

#### 2. Backend (`backend`)
```yaml
build: users/backend/Dockerfile
puerto: 5001 → 8000
dependencias: db (healthy)
```

**Características:**
- Flask + Gunicorn
- 3 workers, 2 threads por worker
- Espera a que DB esté saludable
- Variables de entorno para configuración

#### 3. Frontend (`frontend`)
```yaml
build: Dockerfile
puertos: 80, 443
dependencias: backend
extra_hosts: host.docker.internal
```

**Características:**
- Nginx + Gunicorn + Flask
- SSL/TLS habilitado
- Proxy reverso a backend
- Sirve archivos estáticos

### Comandos Docker Útiles

```bash
# Construcción y ejecución
docker-compose up -d                    # Iniciar en background
docker-compose up --build               # Reconstruir e iniciar
docker-compose build --no-cache         # Reconstruir desde cero

# Gestión de servicios
docker-compose start                    # Iniciar servicios detenidos
docker-compose stop                     # Detener servicios
docker-compose restart                  # Reiniciar servicios
docker-compose down                     # Detener y eliminar contenedores
docker-compose down -v                  # Incluye volúmenes

# Logs y monitoreo
docker-compose logs                     # Ver todos los logs
docker-compose logs -f frontend         # Seguir logs del frontend
docker-compose logs --tail=100 backend  # Últimas 100 líneas del backend
docker-compose ps                       # Estado de servicios
docker-compose top                      # Procesos en ejecución

# Debugging
docker exec -it miniweb-frontend bash   # Shell en frontend
docker exec -it miniweb-backend bash    # Shell en backend
docker exec -it miniweb-db mysql -u root -proot  # MySQL CLI

# Limpieza
docker system prune                     # Limpiar recursos no usados
docker volume prune                     # Eliminar volúmenes no usados
docker image prune -a                   # Eliminar imágenes no usadas
```