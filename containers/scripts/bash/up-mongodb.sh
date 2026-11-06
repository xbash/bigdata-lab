#!/usr/bin/env bash
# Levanta el stack base junto con el overlay nosql-mongodb de lab08.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"

printf "\n===== LEVANTANDO OVERLAY NOSQL-MONGODB =====\n\n"

dirs=(
  "profiles/nosql-mongodb"
  "data/shared/lab08/scripts"
  "data/shared/lab08/results"
  "data/shared/lab08/notes"
  "data/shared/lab08/datasets"
)

for dir in "${dirs[@]}"; do
  mkdir -p "$dir"
done

podman compose -f ./compose.yml -f ./compose.mongodb.yml up -d
