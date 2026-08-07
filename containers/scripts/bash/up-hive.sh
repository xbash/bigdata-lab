#!/usr/bin/env bash
# Levanta el stack base junto con el overlay sql-hive.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"
env_file="$(get_project_env_file "$root")"

printf "\n===== LEVANTANDO OVERLAY SQL-HIVE =====\n\n"

dirs=(
  "conf/hive"
  "conf/hue"
  "data/hive/warehouse"
  "data/hue"
  "profiles/sql-hive"
)

for dir in "${dirs[@]}"; do
  mkdir -p "$dir"
done

podman compose --env-file "$env_file" -f ./compose.yml -f ./compose.hive.yml up -d
