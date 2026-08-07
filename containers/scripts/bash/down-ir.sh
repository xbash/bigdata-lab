#!/usr/bin/env bash
# Detiene y baja el stack base junto con el overlay IR.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"
env_file="$(get_project_env_file "$root")"

printf "\n===== BAJANDO OVERLAY IR =====\n\n"

podman compose --env-file "$env_file" -f ./compose.yml -f ./compose.ir.yml down
