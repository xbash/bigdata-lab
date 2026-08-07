#!/usr/bin/env bash
# Reconstruye desde cero las imagenes base del stack reusable sin cache.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(resolve_project_root)"
cd "$root"
load_project_env "$root"

printf "\n===== CONSTRUCCION LIMPIA DE IMAGENES =====\n\n"

IMAGE_TAG="${BIGDATA_IMAGE_TAG:?BIGDATA_IMAGE_TAG no esta definido en conf/image-tags.conf ni en el entorno}"
PIG_ARCHIVE_DIRNAME="${PIG_ARCHIVE_DIRNAME:-pig-0.18.0}"
CASSANDRA_VERSION="${CASSANDRA_VERSION:-2.0.7}"
PIG_ARCHIVE_PATH=".artifacts/pig-0.18.0-SNAPSHOT-course.tgz"
PIG_ARCHIVE_SHA256_PATH=".artifacts/pig-0.18.0-SNAPSHOT-course.tgz.sha256"

if [ ! -f "${PIG_ARCHIVE_PATH}" ]; then
  echo "Missing required course Pig artifact: ${PIG_ARCHIVE_PATH}" >&2
  exit 1
fi

if [ ! -f "${PIG_ARCHIVE_SHA256_PATH}" ]; then
  echo "Missing required course Pig SHA256 file: ${PIG_ARCHIVE_SHA256_PATH}" >&2
  exit 1
fi

PIG_ARCHIVE_SHA256="$(tr -d '\r\n' < "${PIG_ARCHIVE_SHA256_PATH}" | tr '[:lower:]' '[:upper:]')"
ACTUAL_PIG_ARCHIVE_SHA256="$(sha256sum "${PIG_ARCHIVE_PATH}" | awk '{print toupper($1)}')"

if [ -z "${PIG_ARCHIVE_SHA256}" ]; then
  echo "Course Pig SHA256 file is empty: ${PIG_ARCHIVE_SHA256_PATH}" >&2
  exit 1
fi

if [ "${ACTUAL_PIG_ARCHIVE_SHA256}" != "${PIG_ARCHIVE_SHA256}" ]; then
  echo "Course Pig artifact SHA256 mismatch. Expected=${PIG_ARCHIVE_SHA256} Actual=${ACTUAL_PIG_ARCHIVE_SHA256}" >&2
  exit 1
fi

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
  "data/shared/lab05/work"
  "conf/elasticsearch"
)

for dir in "${dirs[@]}"; do
  mkdir -p "$dir"
done

podman build --no-cache --build-arg PIG_ARCHIVE_DIRNAME="${PIG_ARCHIVE_DIRNAME}" --build-arg PIG_ARCHIVE_SHA256="${PIG_ARCHIVE_SHA256}" --build-arg CASSANDRA_VERSION="${CASSANDRA_VERSION}" -f ./containers/base/Containerfile -t "bigdata-core-base:${IMAGE_TAG}" .
podman build --no-cache --build-arg PIG_ARCHIVE_DIRNAME="${PIG_ARCHIVE_DIRNAME}" --build-arg PIG_ARCHIVE_SHA256="${PIG_ARCHIVE_SHA256}" -f ./containers/master/Containerfile -t "bigdata-master:${IMAGE_TAG}" .
podman build --no-cache --build-arg PIG_ARCHIVE_DIRNAME="${PIG_ARCHIVE_DIRNAME}" --build-arg PIG_ARCHIVE_SHA256="${PIG_ARCHIVE_SHA256}" -f ./containers/worker/Containerfile -t "bigdata-worker:${IMAGE_TAG}" .
podman build --no-cache -f ./containers/sql-ui/Containerfile -t "bigdata-sql-ui:${IMAGE_TAG}" .
