# Guía rápida de despliegue - Twenty CRM

Esta es la versión que uso cuando necesito volver a desplegar Twenty de forma rápida.

## Qué pasó
El problema más frecuente en mi primer despliegue fue que el archivo `.env` tenía variables críticas comentadas o incompletas, especialmente las de la base de datos.

## Pasos rápidos

1. Abre PowerShell.
2. Navega al directorio del proyecto.
3. Copia la plantilla de entorno si no tienes `.env`:

```powershell
Copy-Item .env.example .env
```

4. Edita `.env` y completa tus valores locales:

```powershell
notepad .env
```

5. Ejecuta el despliegue:

```powershell
.\deploy.ps1 -Action deploy
```

## Alternativa manual

```powershell
docker compose down -v
docker compose up -d --pull always
Start-Sleep -Seconds 60
docker compose ps
```

## Qué verificar

- Docker Desktop debe estar ejecutándose.
- El archivo `.env` debe existir.
- Las variables de PostgreSQL deben estar definidas y sin `#`.
- El puerto `3000` debe estar libre o redirigido según tu configuración.

## Si algo falla

Revisa primero `TROUBLESHOOTING.md` y luego `DEPLOYMENT_GUIDE.md` si necesitas un diagnóstico más profundo.
