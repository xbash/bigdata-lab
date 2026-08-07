#!/usr/bin/env bash
# Muestra el estado del stack base mas el overlay sql-hive y consulta endpoints expuestos.
set -euo pipefail

command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }
curl_bin="$(command -v curl || true)"

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"
env_file="$(get_project_env_file "$root")"

printf "\n===== ESTADO OVERLAY SQL-HIVE =====\n"

printf "\n== podman compose ps (core + sql-hive) ==\n"
podman compose --env-file "$env_file" -f ./compose.yml -f ./compose.hive.yml ps

printf "\n== podman ps ==\n"
podman ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

printf "\n== hue (localhost:8888) ==\n"
if [[ -n "$curl_bin" ]]; then
  "$curl_bin" -fsSI http://localhost:8888 | head -n 1 || true
else
  echo "curl no esta disponible en PATH." >&2
fi

printf "\n== hiveserver2 web (localhost:10002) ==\n"
if [[ -n "$curl_bin" ]]; then
  "$curl_bin" -fsSI http://localhost:10002 | head -n 1 || true
else
  echo "curl no esta disponible en PATH." >&2
fi

printf "\n== puertos TCP ==\n"
for port in 9083 10000; do
  if (echo > "/dev/tcp/127.0.0.1/${port}") >/dev/null 2>&1; then
    echo "localhost:${port} -> OPEN"
  else
    echo "localhost:${port} -> CLOSED"
  fi
done
