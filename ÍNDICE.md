# Índice de documentación - Twenty CRM con Docker

Este repositorio contiene documentación para desplegar Twenty en un entorno local con Docker.

## Orden recomendado de lectura

1. `README_DESPLIEGUE.md` - resumen rápido de despliegue.
2. `CHECKLIST.md` - verificación antes de ejecutar.
3. `DEPLOYMENT_GUIDE.md` - guía detallada completa.
4. `TROUBLESHOOTING.md` - soluciones a fallos comunes.

## Archivos clave

- `README.md` - descripción general del repositorio.
- `deploy.ps1` - script de despliegue automatizado.
- `.env.example` - plantilla de variables de entorno.

## Consejos rápidos

- Copia `.env.example` a `.env` antes de ejecutar.
- No subas `.env` al repositorio.
- Ejecuta `docker compose down -v` antes de un nuevo despliegue.
- Accede a la aplicación en `http://localhost:3000`.

## Comandos básicos

| Necesito... | Documento |
|---|---|
| Desplegar rápido | `README_DESPLIEGUE.md` |
| Revisar previo | `CHECKLIST.md` |
| Entender todo | `DEPLOYMENT_GUIDE.md` |
| Solucionar errores | `TROUBLESHOOTING.md` |
| Automatizar despliegue | `deploy.ps1` |

## Flujo recomendado

1. Leer `CHECKLIST.md`.
2. Ejecutar `deploy.ps1` o el comando manual.
3. Verificar los servicios con `docker compose ps`.
4. Abrir `http://localhost:3000`.

## Notas de seguridad

- Usa variables de entorno seguras.
- No compartas claves ni contraseñas.
- Mantén `.env` fuera de Git.
