#!/usr/bin/env bash
# Abre una shell interactiva dentro del contenedor Elasticsearch del overlay IR.
set -euo pipefail

command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

printf "\n===== SHELL EN BIGDATA-ELASTICSEARCH =====\n\n"

exec podman exec -it bigdata-elasticsearch /bin/bash
