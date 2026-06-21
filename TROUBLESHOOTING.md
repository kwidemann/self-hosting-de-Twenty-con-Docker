# Troubleshooting de Twenty CRM con Docker

Esta guía reúne los errores más comunes que encontré al desplegar Twenty y cómo resolverlos.

## 1. Error: "password authentication failed for user postgres"

**Qué indica:** La aplicación no puede conectarse a PostgreSQL porque las credenciales no coinciden.

**Qué revisar:**

- El archivo `.env` existe.
- `PG_DATABASE_USER`, `PG_DATABASE_PASSWORD`, `PG_DATABASE_HOST` y `PG_DATABASE_PORT` están definidos.
- Las variables no están comentadas.

**Solución:**

```powershell
docker compose down -v
notepad .env
```

Asegúrate de que `PG_DATABASE_PASSWORD` tenga un valor válido y guarda el archivo.

## 2. Error: "port 3000 is already in use"

**Qué indica:** Otro proceso usa el puerto local 3000.

**Solución:**

```powershell
Get-NetTCPConnection -LocalPort 3000
```

Si es necesario, cambia el puerto en `docker-compose.yml`:

```yaml
ports:
  - "8080:3000"
```

## 3. Error: "relation does not exist"

**Qué indica:** Las migraciones de la base de datos no han terminado.

**Solución:**

```powershell
docker logs -f twenty-server-1 | Select-String "migration"
```

Espera unos minutos y reinicia si es necesario:

```powershell
docker compose restart twenty-server-1
```

## 4. Error: "Docker daemon is not running"

**Qué indica:** Docker Desktop no está activo.

**Solución:**

- Abre Docker Desktop.
- Espera a que termine de arrancar.
- Ejecuta `docker ps` de nuevo.

## 5. Error: "no such file or directory: docker-compose.yml"

**Qué indica:** Estás en el directorio equivocado o el archivo no existe.

**Solución:**

```powershell
pwd
ls docker-compose.*
```

Asegúrate de ejecutar los comandos desde la carpeta raíz del proyecto.

## Comprobaciones generales

```powershell
docker compose ps
docker system df
docker logs twenty-server-1 -n 50
```

## Último recurso: reinicio completo

```powershell
docker compose down -v
docker system prune -a -f
docker compose up -d --pull always
```

> Esta operación borra todos los datos del proyecto local.
