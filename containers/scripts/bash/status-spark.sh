#!/usr/bin/env bash
# Muestra el estado del stack base mas el overlay Spark.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"
env_file="$(get_project_env_file "$root")"

printf "\n===== ESTADO OVERLAY SPARK =====\n"

printf "\n== podman compose ps (core + spark) ==\n"
podman compose --env-file "$env_file" -f ./compose.yml -f ./compose.spark.yml ps

printf "\n== podman ps ==\n"
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

printf "\n== spark processes (master) ==\n"
if ! podman exec bigdata-master /bin/bash -lc "jps | grep -E 'Master|Worker' || true"; then
  echo "No fue posible consultar los procesos Spark en bigdata-master." >&2
fi

printf "\n== spark master web (localhost:8080) ==\n"
if command -v curl >/dev/null 2>&1; then
  if ! curl -fsS -o /dev/null -w "%{http_code}\n" "http://localhost:8080"; then
    echo "No fue posible consultar Spark Master en http://localhost:8080" >&2
  fi
else
  echo "curl no esta disponible; omitiendo consulta HTTP a Spark Master." >&2
fi
