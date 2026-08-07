#!/usr/bin/env bash
# Abre una shell interactiva dentro del contenedor sql-ui del overlay sql-hive.
set -euo pipefail

command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

printf "\n===== SHELL EN BIGDATA-SQL-UI =====\n\n"

exec podman exec -it bigdata-sql-ui /bin/bash
