#!/usr/bin/env bash
# Levanta el stack base junto con el overlay Spark de lab04.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"
env_file="$(get_project_env_file "$root")"

printf "\n===== LEVANTANDO OVERLAY SPARK =====\n\n"

dirs=(
  "data/namenode"
  "data/datanode1"
  "data/datanode2"
  "data/datanode3"
  "data/shared"
  "data/outputs"
  "logs"
  "evidencia"
)

for dir in "${dirs[@]}"; do
  mkdir -p "$dir"
done

podman compose --env-file "$env_file" -f ./compose.yml -f ./compose.spark.yml up -d
