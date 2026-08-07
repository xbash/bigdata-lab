#!/usr/bin/env bash

resolve_project_root() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "${script_dir}/../../.." && pwd
}

get_project_env_file() {
  local root="${1:?root requerido}"
  printf '%s\n' "${root}/conf/image-tags.conf"
}

load_project_env() {
  local root="${1:?root requerido}"
  local env_file
  env_file="$(get_project_env_file "${root}")"

  if [ ! -f "${env_file}" ]; then
    echo "No se encontro el archivo de variables del proyecto: ${env_file}" >&2
    return 1
  fi

  while IFS='=' read -r key value; do
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"

    if [ -z "${key}" ] || [[ "${key}" == \#* ]]; then
      continue
    fi

    export "${key}=${value}"
  done < "${env_file}"
}
