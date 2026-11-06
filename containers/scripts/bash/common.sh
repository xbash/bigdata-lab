#!/usr/bin/env bash

resolve_project_root() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "${script_dir}/../../.." && pwd
}

get_project_env_file() {
  local root="${1:?root requerido}"
  printf '%s
' "${root}/VERSION"
}

load_project_env() {
  local root="${1:?root requerido}"
  local version_file version
  version_file="$(get_project_env_file "${root}")"

  if [ ! -f "${version_file}" ]; then
    echo "No se encontro el archivo de version del proyecto: ${version_file}" >&2
    return 1
  fi

  version="$(tr -d '[:space:]' < "${version_file}")"
  if [ -z "${version}" ]; then
    echo "El archivo de version del proyecto esta vacio: ${version_file}" >&2
    return 1
  fi

  # Compose toma BIGDATA_IMAGE_TAG del entorno; no se pasa --env-file.
  export BIGDATA_IMAGE_TAG="${BIGDATA_IMAGE_TAG:-${version}}"
}
