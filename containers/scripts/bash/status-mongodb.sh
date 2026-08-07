#!/usr/bin/env bash
# Muestra el estado del stack base mas el overlay nosql-mongodb.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"
env_file="$(get_project_env_file "$root")"

printf "\n===== ESTADO OVERLAY NOSQL-MONGODB =====\n"

printf "\n== podman compose ps (core + mongodb) ==\n"
podman compose --env-file "$env_file" -f ./compose.yml -f ./compose.mongodb.yml ps

printf "\n== podman ps ==\n"
podman ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

printf "\n== mongo ping (bigdata-mongodb) ==\n"
podman exec bigdata-mongodb mongo --quiet --eval 'db.adminCommand({ ping: 1 })' || echo "No fue posible ejecutar el ping de MongoDB en bigdata-mongodb." >&2

printf "\n== show dbs (bigdata-mongodb) ==\n"
podman exec bigdata-mongodb mongo --quiet --eval 'show dbs' || echo "No fue posible listar las bases de datos en bigdata-mongodb." >&2
