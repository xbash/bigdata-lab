#!/usr/bin/env bash
# Muestra el estado del stack base mas el overlay IR y consulta Elasticsearch.
set -euo pipefail

command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }
curl_bin="$(command -v curl || true)"

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"
env_file="$(get_project_env_file "$root")"

printf "\n===== ESTADO OVERLAY IR =====\n"

printf "\n== podman compose ps (core + ir) ==\n"
podman compose --env-file "$env_file" -f ./compose.yml -f ./compose.ir.yml ps

printf "\n== podman ps ==\n"
podman ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

printf "\n== elasticsearch health (localhost:9200) ==\n"
if [[ -n "$curl_bin" ]]; then
  "$curl_bin" -fsS http://localhost:9200/_cat/health?v || true
else
  echo "curl no esta disponible en PATH." >&2
fi

printf "\n== elasticsearch nodes (localhost:9200) ==\n"
if [[ -n "$curl_bin" ]]; then
  "$curl_bin" -fsS http://localhost:9200/_cat/nodes?v || true
else
  echo "curl no esta disponible en PATH." >&2
fi
