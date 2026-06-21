# Guía completa de despliegue de Twenty CRM

Esta guía documenta el proceso completo que seguí para desplegar Twenty con Docker en Windows.

## Requisitos

- Windows con Docker Desktop instalado.
- Docker Compose disponible.
- PowerShell.
- Un directorio local para el proyecto.

## Preparar la configuración

1. Clona este repositorio en tu carpeta local.
2. Navega al directorio del proyecto.

```powershell
cd <ruta-del-proyecto>
```

3. Crea el archivo `.env` desde la plantilla:

```powershell
Copy-Item .env.example .env
```

4. Edita `.env` y ajusta los valores de tu entorno:

```powershell
notepad .env
```

### Variables clave en `.env`

Asegúrate de que estas líneas existan y no estén comentadas:

```ini
PG_DATABASE_USER=postgres
PG_DATABASE_PASSWORD=replace_with_secure_password
PG_DATABASE_HOST=db
PG_DATABASE_PORT=5432
REDIS_URL=redis://redis:6379
```

También configura la URL del servidor y las claves necesarias:

```ini
SERVER_URL=http://localhost:3000
ENCRYPTION_KEY=replace_with_secure_key
FALLBACK_ENCRYPTION_KEY=
APP_SECRET=replace_with_secure_secret
STORAGE_TYPE=local
```

> No compartas tus valores reales en un repositorio público.

## Validar la configuración

Verifica que el comando Docker Compose sea válido:

```powershell
docker compose config
```

## Despliegue inicial

1. Detén y limpia cualquier despliegue anterior:

```powershell
docker compose down -v
```

2. Levanta los contenedores:

```powershell
docker compose up -d --pull always
```

3. Espera 30-60 segundos y revisa el estado:

```powershell
docker compose ps
```

## Comprobaciones después del despliegue

- El contenedor de base de datos debe mostrar `Healthy`.
- El contenedor de Redis debe mostrar `Healthy`.
- El servidor de Twenty debe estar `Running` o `Healthy`.

Revisa los logs del servidor:

```powershell
docker logs twenty-server-1
```

## Acceder a la aplicación

Abre en el navegador:

```text
http://localhost:3000
```

## Detener y limpiar

- Para detener sin borrar datos:

```powershell
docker compose stop
```

- Para detener y eliminar volúmenes de datos:

```powershell
docker compose down -v
```

## Recomendaciones de seguridad

- Añade `.env` a `.gitignore`.
- No subas `.env` a GitHub.
- Usa `.env.example` como plantilla.
