# Self-hosting de Twenty con Docker

Este repositorio documenta el proceso que seguí para desplegar el CRM de código abierto **Twenty** en Windows usando Docker Desktop y Docker Compose.

El objetivo es que cualquier persona pueda reproducir la instalación, entender los pasos clave y volver a desplegar rápidamente si es necesario.

## Resumen

- Instalé Twenty en Windows usando Docker Desktop.
- Verifiqué las versiones de Docker y Docker Compose.
- Descargué o creé los archivos de despliegue (`docker-compose.yml` y `.env`).
- Edité `.env` con mis valores locales.
- Documenté los problemas y soluciones para futuros despliegues.

## Requisitos previos

Antes de empezar, debes tener instalado:

- Windows
- Docker Desktop
- Docker Compose (incluido en Docker Desktop)
- PowerShell

Verifica el entorno con:

```powershell
docker --version
docker compose version
docker ps
```

## Preparar el entorno local

1. Crea el directorio donde trabajarás.
2. Navega a ese directorio en PowerShell.

## Configurar `.env`

Este repositorio incluye una plantilla `./.env.example`.
Para iniciar, copia esa plantilla a `.env`:

```powershell
Copy-Item .env.example .env
```

Luego edita el archivo:

```powershell
notepad .env
```

> Nunca compartas tus credenciales ni valores privados en GitHub.

## Despliegue

Después de configurar `.env`, levanta el proyecto con:

```powershell
docker compose up -d
```

Y verifica los servicios con:

```powershell
docker compose ps
docker ps
```

## Buenas prácticas

- Usa `.env.example` como plantilla.
- No subas `.env` al repositorio.
- Mantén `.env` fuera del control de versiones.
- Si usas `docker compose`, preferir `down -v` antes de un nuevo despliegue.

## Documentación adicional

- `README_DESPLIEGUE.md` — resumen rápido para re-desplegar.
- `CHECKLIST.md` — pasos previos antes de cada ejecución.
- `DEPLOYMENT_GUIDE.md` — guía completa.
- `TROUBLESHOOTING.md` — solución de errores comunes.
