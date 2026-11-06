#!/usr/bin/env bash
set -euo pipefail

if [[ "${ENABLE_CASSANDRA:-false}" != "true" ]]; then
  exit 0
fi

export BIGDATA_HOME="${BIGDATA_HOME:-/opt/bigdata}"
export CASSANDRA_HOME="${CASSANDRA_HOME:-/opt/bigdata/cassandra}"
export CASSANDRA_LOG_DIR="${CASSANDRA_LOG_DIR:-/opt/bigdata/logs/cassandra}"
export CASSANDRA_DATA_DIR="${CASSANDRA_DATA_DIR:-/opt/bigdata/data/cassandra}"
export CASSANDRA_CONF="${CASSANDRA_CONF:-${CASSANDRA_DATA_DIR}/conf}"
export JAVA_HOME="${JAVA_HOME:-/opt/java/openjdk}"

CASSANDRA_NODE_NAME="${CASSANDRA_NODE_NAME:-$(hostname)}"
CASSANDRA_LISTEN_ADDRESS="${CASSANDRA_LISTEN_ADDRESS:-$(hostname)}"
CASSANDRA_RPC_ADDRESS="${CASSANDRA_RPC_ADDRESS:-0.0.0.0}"
CASSANDRA_SEEDS="${CASSANDRA_SEEDS:-master}"
CASSANDRA_CLUSTER_NAME="${CASSANDRA_CLUSTER_NAME:-Cassandra Cluster}"
CASSANDRA_NATIVE_TRANSPORT_PORT="${CASSANDRA_NATIVE_TRANSPORT_PORT:-9042}"
CASSANDRA_RPC_PORT="${CASSANDRA_RPC_PORT:-9160}"
CASSANDRA_STORAGE_PORT="${CASSANDRA_STORAGE_PORT:-7000}"
CASSANDRA_SSL_STORAGE_PORT="${CASSANDRA_SSL_STORAGE_PORT:-7001}"
CASSANDRA_JMX_PORT="${CASSANDRA_JMX_PORT:-7199}"

mkdir -p \
  "${CASSANDRA_CONF}" \
  "${CASSANDRA_DATA_DIR}/data" \
  "${CASSANDRA_DATA_DIR}/commitlog" \
  "${CASSANDRA_DATA_DIR}/saved_caches" \
  "${CASSANDRA_DATA_DIR}/hints" \
  "${CASSANDRA_LOG_DIR}"

cp -R "${CASSANDRA_HOME}/conf/." "${CASSANDRA_CONF}/"

python3 - <<PY
from pathlib import Path

yaml_path = Path("${CASSANDRA_CONF}") / "cassandra.yaml"
text = yaml_path.read_text(encoding="utf-8")

replacements = {
    "cluster_name": "'${CASSANDRA_CLUSTER_NAME}'",
    "num_tokens": "256",
    "partitioner": "org.apache.cassandra.dht.Murmur3Partitioner",
    "commitlog_directory": "${CASSANDRA_DATA_DIR}/commitlog",
    "saved_caches_directory": "${CASSANDRA_DATA_DIR}/saved_caches",
    "storage_port": "${CASSANDRA_STORAGE_PORT}",
    "ssl_storage_port": "${CASSANDRA_SSL_STORAGE_PORT}",
    "listen_address": "${CASSANDRA_LISTEN_ADDRESS}",
    "start_native_transport": "true",
    "native_transport_port": "${CASSANDRA_NATIVE_TRANSPORT_PORT}",
    "start_rpc": "true",
    "rpc_address": "${CASSANDRA_RPC_ADDRESS}",
    "rpc_port": "${CASSANDRA_RPC_PORT}",
    "endpoint_snitch": "SimpleSnitch",
}

lines = text.splitlines()
output = []
skip_data_dirs = False
for line in lines:
    stripped = line.strip()
    if skip_data_dirs:
        if stripped.startswith("-") or not stripped:
            continue
        skip_data_dirs = False
    if line.startswith("data_file_directories:"):
        output.append("data_file_directories:")
        output.append("    - ${CASSANDRA_DATA_DIR}/data")
        skip_data_dirs = True
        continue
    if "          - seeds:" in line:
        output.append('          - seeds: "${CASSANDRA_SEEDS}"')
        continue
    key = line.split(":", 1)[0] if ":" in line and not line.startswith(" ") else None
    if key in replacements:
        output.append(f"{key}: {replacements[key]}")
        continue
    output.append(line)

yaml_path.write_text("\\n".join(output) + "\\n", encoding="utf-8")
PY

cat > "${CASSANDRA_CONF}/cassandra-env.sh" <<EOF
MAX_HEAP_SIZE="${CASSANDRA_MAX_HEAP_SIZE:-512M}"
HEAP_NEWSIZE="${CASSANDRA_HEAP_NEWSIZE:-128M}"
JVM_OPTS="\$JVM_OPTS -Djava.net.preferIPv4Stack=true"
JVM_OPTS="\$JVM_OPTS -Dcom.sun.management.jmxremote.port=${CASSANDRA_JMX_PORT}"
JVM_OPTS="\$JVM_OPTS -Dcom.sun.management.jmxremote.rmi.port=${CASSANDRA_JMX_PORT}"
JVM_OPTS="\$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=false"
JVM_OPTS="\$JVM_OPTS -Dcom.sun.management.jmxremote.authenticate=false"
JVM_OPTS="\$JVM_OPTS -Djava.rmi.server.hostname=${CASSANDRA_LISTEN_ADDRESS}"
JVM_OPTS="\$JVM_OPTS --add-exports java.base/jdk.internal.misc=ALL-UNNAMED"
JVM_OPTS="\$JVM_OPTS --add-exports java.base/jdk.internal.ref=ALL-UNNAMED"
JVM_OPTS="\$JVM_OPTS --add-exports java.base/sun.nio.ch=ALL-UNNAMED"
JVM_OPTS="\$JVM_OPTS --add-exports java.management.rmi/com.sun.jmx.remote.internal.rmi=ALL-UNNAMED"
JVM_OPTS="\$JVM_OPTS --add-exports java.rmi/sun.rmi.registry=ALL-UNNAMED"
JVM_OPTS="\$JVM_OPTS --add-exports java.rmi/sun.rmi.server=ALL-UNNAMED"
JVM_OPTS="\$JVM_OPTS --add-opens java.base/java.lang.module=ALL-UNNAMED"
JVM_OPTS="\$JVM_OPTS --add-opens java.base/jdk.internal.loader=ALL-UNNAMED"
JVM_OPTS="\$JVM_OPTS --add-opens java.base/jdk.internal.ref=ALL-UNNAMED"
JVM_OPTS="\$JVM_OPTS --add-opens java.base/jdk.internal.reflect=ALL-UNNAMED"
JVM_OPTS="\$JVM_OPTS --add-opens java.base/jdk.internal.math=ALL-UNNAMED"
JVM_OPTS="\$JVM_OPTS --add-opens java.base/jdk.internal.module=ALL-UNNAMED"
EOF

if pgrep -f "org.apache.cassandra.service.CassandraDaemon" >/dev/null 2>&1; then
  echo "cassandra already running on ${CASSANDRA_NODE_NAME}"
  exit 0
fi

echo "starting cassandra ${CASSANDRA_NODE_NAME} listen=${CASSANDRA_LISTEN_ADDRESS} seeds=${CASSANDRA_SEEDS}"
"${CASSANDRA_HOME}/bin/cassandra" \
  -Dcassandra.config="file://${CASSANDRA_CONF}/cassandra.yaml" \
  -p "${CASSANDRA_DATA_DIR}/cassandra.pid" \
  >> "${CASSANDRA_LOG_DIR}/cassandra-${CASSANDRA_NODE_NAME}.log" 2>&1
