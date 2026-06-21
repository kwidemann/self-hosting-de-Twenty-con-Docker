# Checklist previo a un despliegue de Twenty CRM

Uso este checklist antes de cada despliegue para evitar errores básicos.

## Antes de empezar

- [ ] Docker Desktop está abierto y funcionando.

```powershell
docker ps
```

- [ ] Estoy en el directorio raíz del proyecto.

```powershell
pwd
```

- [ ] El archivo `.env` existe.

```powershell
Test-Path .env
```

- [ ] Las variables de base de datos están definidas y no están comentadas.

```powershell
Select-String -Path .env -Pattern '^PG_DATABASE_'
```

- [ ] No hay contenedores viejos del proyecto en ejecución.

```powershell
docker compose ps
```

## Despliegue

- [ ] Limpiar contenedores anteriores si es necesario.

```powershell
docker compose down -v
```

- [ ] Levantar los servicios.

```powershell
docker compose up -d --pull always
```

- [ ] Esperar 30-60 segundos.

```powershell
Start-Sleep -Seconds 60
```

- [ ] Verificar estado.

```powershell
docker compose ps
```

## Verificación rápida

- [ ] Todos los servicios esperados están en estado `Running` o `Healthy`.
- [ ] No hay errores evidentes en los logs.
- [ ] La aplicación responde en `http://localhost:3000`.

## Nota de seguridad

- No publiques `.env` en GitHub.
- Usa `.env.example` como plantilla.
