#!/usr/bin/env bash
# Abre una shell interactiva de MongoDB dentro del contenedor del overlay.
set -euo pipefail

command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

printf "\n===== SHELL MONGODB EN BIGDATA-MONGODB =====\n\n"

podman exec -it bigdata-mongodb mongo
