#!/bin/bash
# Aplica init.sql solo si ComercialLaEstrella todavia no existe.
set -euo pipefail

SERVER="${SQL_SERVER:-sqlserver}"
USER_NAME="${SQL_USER:-sa}"
PASSWORD="${SA_PASSWORD:?SA_PASSWORD requerido}"

if [ -x /opt/mssql-tools18/bin/sqlcmd ]; then
  SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
elif [ -x /opt/mssql-tools/bin/sqlcmd ]; then
  SQLCMD="/opt/mssql-tools/bin/sqlcmd"
else
  echo "No se encontro sqlcmd en la imagen." >&2
  exit 1
fi

echo "Esperando a SQL Server en ${SERVER}..."
ready=0
for _ in $(seq 1 60); do
  if "$SQLCMD" -S "$SERVER" -U "$USER_NAME" -P "$PASSWORD" -C -b -Q "SELECT 1" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 2
done

if [ "$ready" -ne 1 ]; then
  echo "SQL Server no acepto conexiones a tiempo." >&2
  exit 1
fi

EXISTS="$("$SQLCMD" -S "$SERVER" -U "$USER_NAME" -P "$PASSWORD" -C -h -1 -W -b -Q "SET NOCOUNT ON; SELECT CASE WHEN DB_ID(N'ComercialLaEstrella') IS NULL THEN 0 ELSE 1 END" | tr -d '[:space:]')"

if [ "$EXISTS" = "1" ]; then
  echo "La base ComercialLaEstrella ya existe. init.sql no se vuelve a ejecutar."
  echo "Para cargar de nuevo: docker compose down -v && docker compose up -d"
  exit 0
fi

echo "Creando la base y cargando el dataset de la Fase 1..."
"$SQLCMD" -S "$SERVER" -U "$USER_NAME" -P "$PASSWORD" -C -I -b -i /scripts/init.sql
echo "Inicializacion completada."
