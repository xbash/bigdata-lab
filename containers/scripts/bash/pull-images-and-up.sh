#!/usr/bin/env bash
# Descarga las imagenes publicadas, las etiqueta localmente y levanta el stack sin rebuild.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"
env_file="$(get_project_env_file "$root")"
tag="${1:-${BIGDATA_IMAGE_TAG:?BIGDATA_IMAGE_TAG no esta definido en conf/image-tags.conf ni en el entorno}}"

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

images=(
  "docker.io/xbash/bigdata-core-base:${tag}|bigdata-core-base:${tag}"
  "docker.io/xbash/bigdata-master:${tag}|bigdata-master:${tag}"
  "docker.io/xbash/bigdata-worker:${tag}|bigdata-worker:${tag}"
  "docker.io/xbash/bigdata-sql-ui:${tag}|bigdata-sql-ui:${tag}"
)

for image in "${images[@]}"; do
  remote_image="${image%%|*}"
  local_image="${image##*|}"
  podman pull "$remote_image"
  podman tag "$remote_image" "$local_image"
done

podman compose --env-file "$env_file" -f ./compose.yml up -d --no-build
