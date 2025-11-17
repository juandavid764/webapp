# Configuración HTTPS para la Aplicación Web

## Resumen

Se ha configurado Nginx con HTTPS usando un certificado SSL autofirmado integrado en el contenedor del frontend.

## Arquitectura Implementada

### Servicios Docker

1. **db** (MySQL:8.0) - Puerto 3306
   - Base de datos MySQL con tabla de usuarios

2. **backend** (Flask + Gunicorn) - Puerto 5001
   - API REST con endpoints CRUD
   - Expuesto en el host en puerto 5001

3. **frontend** (Flask + Gunicorn + Nginx) - Puertos 80 y 443
   - Nginx como servidor web con SSL
   - Gunicorn sirviendo la aplicación Flask internamente (puerto 8080)
   - Nginx actúa como reverse proxy

### Flujo de Peticiones

```
Cliente (HTTPS/443) 
    ↓
Nginx (Frontend Container)
    ├─→ /api/*  → Backend (host.docker.internal:5001)
    └─→ /*      → Gunicorn local (127.0.0.1:8080)
```

## Certificado SSL

### Generación

Certificado autofirmado válido por 365 días:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/nginx-selfsigned.key \
  -out ssl/nginx-selfsigned.crt \
  -subj "/C=ES/ST=Madrid/L=Madrid/O=Practice/OU=IT/CN=localhost"
```

### Ubicación

- **Host**: `webapp/ssl/`
- **Contenedor**: `/etc/nginx/ssl/`

### Detalles

- **Subject**: CN=localhost, O=Practice, C=ES
- **Validez**: 1 año desde la creación
- **Algoritmo**: RSA 2048 bits

## Configuración de Nginx

### Archivo: `nginx/nginx-frontend.conf`

**Características:**

- **Protocolos SSL**: TLSv1.2 y TLSv1.3
- **Puerto 80**: Redirige automáticamente a HTTPS
- **Puerto 443**: Servidor HTTPS principal

**Rutas:**

- `/api/*` → Proxy al backend vía `host.docker.internal:5001`
- `/*` → Proxy a Gunicorn local (aplicación Flask frontend)

## Archivos Importantes

```
webapp/
├── ssl/
│   ├── nginx-selfsigned.crt          # Certificado SSL
│   └── nginx-selfsigned.key          # Clave privada
├── nginx/
│   ├── nginx-frontend.conf           # Configuración Nginx integrada
│   └── nginx.conf                    # Configuración anterior (no usada)
├── Dockerfile                        # Imagen frontend con Nginx
├── start-frontend.sh                 # Script de inicio
└── docker-compose.yml                # Orquestación
```

## Dockerfile Frontend

El Dockerfile incluye:

1. Instalación de Nginx
2. Instalación de dependencias Python
3. Copia de certificados SSL
4. Copia de configuración de Nginx
5. Script de inicio que ejecuta Gunicorn y Nginx

## Script de Inicio (`start-frontend.sh`)

```bash
#!/bin/bash
# Inicia Gunicorn en segundo plano
gunicorn --bind 127.0.0.1:8080 --workers 2 --threads 4 web.views:app &

# Espera a que Gunicorn inicie
sleep 2

# Inicia Nginx en primer plano
nginx -g 'daemon off;'
```

## Docker Compose

### Configuración del Frontend

```yaml
frontend:
  build:
    context: .
    dockerfile: Dockerfile
  ports:
    - "80:80"
    - "443:443"
  extra_hosts:
    - "host.docker.internal:host-gateway"
```

`extra_hosts` permite al contenedor resolver `host.docker.internal` para acceder al backend vía el puerto expuesto del host.

## Actualización de la Aplicación

### JavaScript (`web/static/script.js`)

Actualizado para usar HTTPS y el endpoint proxied por Nginx:

```javascript
const BACKEND_URL = 'https://localhost/api';
```

## Comandos Útiles

### Levantar los servicios

```bash
cd /home/vagrant/webapp
docker-compose up -d
```

### Reconstruir el frontend

```bash
docker-compose build frontend
docker-compose up -d
```

### Ver logs

```bash
docker logs miniweb-frontend
docker logs miniweb-backend
```

### Verificar certificado

```bash
openssl s_client -connect localhost:443 -showcerts < /dev/null
```

## Acceso a la Aplicación

- **Frontend**: https://localhost
- **API Backend**: https://localhost/api/users
- **Redireccion HTTP**: http://localhost → https://localhost

## Notas de Seguridad

⚠️ **IMPORTANTE**: Este certificado es autofirmado y **solo debe usarse en desarrollo/práctica**.

Los navegadores mostrarán advertencias de seguridad. Para producción se requiere:

- Certificado emitido por una CA confiable (Let's Encrypt, DigiCert, etc.)
- Dominio válido
- Configuración adicional de seguridad

## Verificación de Funcionamiento

### 1. Probar HTTPS

```bash
curl -k https://localhost
```

### 2. Probar API

```bash
curl -k https://localhost/api/users
```

### 3. Verificar redirección HTTP → HTTPS

```bash
curl -I http://localhost
# Debe retornar: 301 Moved Permanently
```

### 4. Ver información del certificado

```bash
openssl s_client -connect localhost:443 2>/dev/null | openssl x509 -noout -dates
```

## Problemas Comunes y Soluciones

### Error: Permission denied en start-frontend.sh

**Solución**: Dar permisos de ejecución

```bash
chmod +x webapp/start-frontend.sh
```

### Error: Backend no responde

**Verificar que `extra_hosts` esté configurado en docker-compose.yml**

### Puerto 443 ocupado

**Solución**: Detener otros servicios usando el puerto

```bash
sudo lsof -i :443
docker-compose down
```
