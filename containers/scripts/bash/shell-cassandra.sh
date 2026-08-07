#!/usr/bin/env bash
# Abre una shell interactiva dentro del contenedor master con Cassandra habilitado.
set -euo pipefail

command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

printf "\n===== SHELL CASSANDRA EN BIGDATA-MASTER =====\n\n"

podman exec -it bigdata-master /bin/bash
