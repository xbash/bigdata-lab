#!/usr/bin/env bash
# Detiene y baja el stack base de contenedores.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"

printf "\n===== BAJANDO STACK BASE =====\n\n"

podman compose -f ./compose.yml down
