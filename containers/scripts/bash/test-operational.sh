#!/usr/bin/env bash
# Ejecuta un set de pruebas operacionales del runtime, excluyendo jobs de datos.
set -euo pipefail

command -v podman >/dev/null 2>&1 || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$root"

printf "\n===== SET DE PRUEBAS OPERACIONALES =====\n\n"

base_containers=(bigdata-master bigdata-worker1 bigdata-worker2 bigdata-worker3)
spark_ports=(http://127.0.0.1:8080)
ir_containers=(bigdata-elasticsearch)
hive_containers=(bigdata-sql-ui bigdata-hive-metastore bigdata-hive-server)

step() {
  printf "\n[%s] %s\n" "TEST" "$1"
}

container_state() {
  local name="$1"
  podman inspect -f '{{.State.Status}}|{{if .State.Health}}{{.State.Health.Status}}{{end}}' "$name" 2>/dev/null || true
}

assert_container_running() {
  local name="$1"
  local state
  state="$(container_state "$name")"
  if [[ -z "$state" ]]; then
    echo "Contenedor no encontrado: $name" >&2
    exit 1
  fi

  local status="${state%%|*}"
  local health="${state#*|}"
  if [[ "$status" != "running" ]]; then
    echo "Contenedor no esta running: $name ($state)" >&2
    exit 1
  fi
  if [[ -n "$health" && "$health" != "healthy" ]]; then
    echo "Contenedor sin health satisfactoria: $name ($state)" >&2
    exit 1
  fi
}

assert_container_absent() {
  local name="$1"
  if podman container exists "$name"; then
    echo "Contenedor aun presente: $name" >&2
    exit 1
  fi
}

wait_running() {
  local timeout="$1"
  shift
  local names=("$@")
  local deadline=$((SECONDS + timeout))

  while (( SECONDS < deadline )); do
    local all_ok=1
    for name in "${names[@]}"; do
      if ! assert_container_running "$name" >/dev/null 2>&1; then
        all_ok=0
        break
      fi
    done
    if (( all_ok == 1 )); then
      return 0
    fi
    sleep 5
  done

  echo "Timeout esperando contenedores: ${names[*]}" >&2
  for name in "${names[@]}"; do
    echo "  - $name => $(container_state "$name")" >&2
  done
  exit 1
}

wait_http() {
  local url="$1"
  local timeout="$2"
  local deadline=$((SECONDS + timeout))

  if command -v curl >/dev/null 2>&1; then
    while (( SECONDS < deadline )); do
      if curl -fsS "$url" >/dev/null 2>&1; then
        return 0
      fi
      sleep 5
    done
  else
    local host_port="${url#http://}"
    host_port="${host_port%%/*}"
    local host="${host_port%%:*}"
    local port="${host_port##*:}"
    while (( SECONDS < deadline )); do
      if (echo > "/dev/tcp/${host}/${port}") >/dev/null 2>&1; then
        return 0
      fi
      sleep 5
    done
  fi

  echo "Timeout esperando endpoint: $url" >&2
  exit 1
}

wait_tcp() {
  local host="$1"
  local port="$2"
  local timeout="$3"
  local deadline=$((SECONDS + timeout))

  while (( SECONDS < deadline )); do
    if (echo > "/dev/tcp/${host}/${port}") >/dev/null 2>&1; then
      return 0
    fi
    sleep 5
  done

  echo "Timeout esperando puerto TCP: ${host}:${port}" >&2
  exit 1
}

assert_exec_success() {
  local name="$1"
  local command="$2"
  if ! podman exec "$name" /bin/bash -lc "$command" >/dev/null; then
    echo "Fallo validacion dentro de $name: $command" >&2
    exit 1
  fi
}

assert_all_absent() {
  local names=("$@")
  for name in "${names[@]}"; do
    assert_container_absent "$name"
  done
}

step "Limpieza inicial con down-all.sh"
bash ./containers/scripts/bash/down-all.sh || true

step "Prueba core: up.sh"
bash ./containers/scripts/bash/up.sh
wait_running 180 "${base_containers[@]}"

step "Prueba core: status.sh"
bash ./containers/scripts/bash/status.sh

step "Prueba core: down.sh"
bash ./containers/scripts/bash/down.sh
assert_all_absent "${base_containers[@]}"

step "Prueba Spark: up-spark.sh"
bash ./containers/scripts/bash/up-spark.sh
wait_running 180 "${base_containers[@]}"
for url in "${spark_ports[@]}"; do
  wait_http "$url" 180
done

step "Prueba Spark: status-spark.sh"
bash ./containers/scripts/bash/status-spark.sh

step "Prueba Spark: down-spark.sh"
bash ./containers/scripts/bash/down-spark.sh
assert_all_absent "${base_containers[@]}"

step "Prueba IR: up-ir.sh"
bash ./containers/scripts/bash/up-ir.sh
wait_running 180 "${base_containers[@]}" "${ir_containers[@]}"
wait_http "http://127.0.0.1:9200/_cat/health?v" 180

step "Prueba IR: status-ir.sh"
bash ./containers/scripts/bash/status-ir.sh

step "Prueba IR: down-ir.sh"
bash ./containers/scripts/bash/down-ir.sh
assert_all_absent "${base_containers[@]}" "${ir_containers[@]}"

step "Prueba sql-hive: up-hive.sh"
bash ./containers/scripts/bash/up-hive.sh
wait_running 300 "${base_containers[@]}" "${hive_containers[@]}"
wait_http "http://127.0.0.1:8888" 300
wait_http "http://127.0.0.1:10002" 300

step "Prueba sql-hive: status-hive.sh"
bash ./containers/scripts/bash/status-hive.sh

step "Prueba sql-hive: down-hive.sh"
bash ./containers/scripts/bash/down-hive.sh
assert_all_absent "${base_containers[@]}" "${hive_containers[@]}"

step "Prueba nosql-cassandra: up-cassandra.sh"
bash ./containers/scripts/bash/up-cassandra.sh
wait_running 240 "${base_containers[@]}"
wait_tcp "127.0.0.1" "9042" 240
assert_exec_success "bigdata-master" "nodetool status >/tmp/nodetool-status.txt 2>&1 && cat /tmp/nodetool-status.txt"
assert_exec_success "bigdata-master" "cqlsh --version >/tmp/cqlsh-version.txt 2>&1 && cat /tmp/cqlsh-version.txt"

step "Prueba nosql-cassandra: status-cassandra.sh"
bash ./containers/scripts/bash/status-cassandra.sh

step "Prueba nosql-cassandra: down-cassandra.sh"
bash ./containers/scripts/bash/down-cassandra.sh
assert_all_absent "${base_containers[@]}"

step "Prueba combinada: up-spark.sh + up-ir.sh + up-hive.sh + down-all.sh"
bash ./containers/scripts/bash/up-spark.sh
wait_running 180 "${base_containers[@]}"
bash ./containers/scripts/bash/up-ir.sh
wait_running 180 "${base_containers[@]}" "${ir_containers[@]}"
bash ./containers/scripts/bash/up-hive.sh
wait_running 300 "${base_containers[@]}" "${ir_containers[@]}" "${hive_containers[@]}"
bash ./containers/scripts/bash/down-all.sh
assert_all_absent "${base_containers[@]}" "${ir_containers[@]}" "${hive_containers[@]}"

cat <<'EOF'

[MANUAL] Wrappers interactivos a revisar
- ./containers/scripts/bash/shell-master.sh
- ./containers/scripts/bash/shell-elastic.sh
- ./containers/scripts/bash/shell-hive.sh
- ./containers/scripts/bash/shell-sql-ui.sh
- ./containers/scripts/bash/shell-cassandra.sh

Criterio de aprobacion manual:
- abre shell dentro del contenedor correcto
- ejecuta `hostname`
- ejecuta `pwd`
- salir con `exit`
EOF

printf "\n[OK] Set de pruebas operacionales completado.\n"
