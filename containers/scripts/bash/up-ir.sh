#!/usr/bin/env bash
# Levanta el stack base junto con el overlay IR de lab05.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"
env_file="$(get_project_env_file "$root")"

printf "\n===== LEVANTANDO OVERLAY IR =====\n\n"

dirs=(
  "conf/elasticsearch"
  "data/shared/lab05/work"
  "data/shared/lab05/results"
  "data/shared/lab05/notes"
)

for dir in "${dirs[@]}"; do
  mkdir -p "$dir"
done

podman compose --env-file "$env_file" -f ./compose.yml -f ./compose.ir.yml up -d
