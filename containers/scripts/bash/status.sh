#!/usr/bin/env bash
# Muestra el estado actual del stack base y de los contenedores Podman.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"

printf "\n===== ESTADO DEL STACK BASE =====\n"

printf "\n== podman compose ps ==\n"
podman compose -f ./compose.yml ps

printf "\n== podman ps ==\n"
podman ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
