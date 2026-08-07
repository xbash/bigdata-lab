#!/usr/bin/env bash
# Levanta en segundo plano el stack base de contenedores.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"
env_file="$(get_project_env_file "$root")"

printf "\n===== LEVANTANDO STACK BASE =====\n\n"

dirs=(
  "data/namenode"
  "data/datanode1"
  "data/datanode2"
  "data/datanode3"
  "data/shared"
  "data/outputs"
  "data/hive"
  "data/hue"
  "conf/hue"
  "logs"
  "evidencia"
  "profiles/sql-hive"
  "profiles/ir"
  "profiles/nosql-cassandra"
  "profiles/nosql-mongodb"
  "profiles/graph"
)

for dir in "${dirs[@]}"; do
  mkdir -p "$dir"
done

podman compose --env-file "$env_file" -f ./compose.yml up -d
