#!/usr/bin/env bash
# Muestra el estado del stack base mas el overlay nosql-cassandra.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"
env_file="$(get_project_env_file "$root")"

printf "\n===== ESTADO OVERLAY NOSQL-CASSANDRA =====\n"

printf "\n== podman compose ps (core + cassandra) ==\n"
podman compose --env-file "$env_file" -f ./compose.yml -f ./compose.cassandra.yml ps

printf "\n== podman ps ==\n"
podman ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

printf "\n== nodetool status (master) ==\n"
podman exec bigdata-master /bin/bash -lc "nodetool status" || echo "No fue posible ejecutar nodetool status en bigdata-master." >&2

printf "\n== cqlsh version (master) ==\n"
podman exec bigdata-master /bin/bash -lc "cqlsh --version" || echo "No fue posible ejecutar cqlsh --version en bigdata-master." >&2

printf "\n== cassandra version (SHOW VERSION) ==\n"
podman exec bigdata-master /bin/bash -lc "echo 'SHOW VERSION;' | cqlsh master" || echo "No fue posible consultar SHOW VERSION en bigdata-master." >&2
