#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

export BIGDATA_HOME="${BIGDATA_HOME:-/opt/bigdata}"
export HADOOP_HOME="${HADOOP_HOME:-/opt/bigdata/hadoop}"
export HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-/opt/bigdata/conf/hadoop}"
export HADOOP_LOG_DIR="${HADOOP_LOG_DIR:-/opt/bigdata/logs/hadoop}"
export HADOOP_PID_DIR="${HADOOP_PID_DIR:-/opt/bigdata/logs/hadoop/pids}"
export YARN_LOG_DIR="${YARN_LOG_DIR:-/opt/bigdata/logs/yarn}"
export JAVA_HOME="${JAVA_HOME:-/opt/java/openjdk}"
export SPARK_HOME="${SPARK_HOME:-/opt/bigdata/spark}"
export SPARK_CONF_DIR="${SPARK_CONF_DIR:-/opt/bigdata/conf/spark}"
export SPARK_LOG_DIR="${SPARK_LOG_DIR:-/opt/bigdata/logs/spark}"

WORKER_NAME="${WORKER_NAME:-worker}"
SPARK_WORKER_WEBUI_PORT="${SPARK_WORKER_WEBUI_PORT:-8081}"

mkdir -p \
  "${BIGDATA_HOME}/data/datanode" \
  "${HADOOP_LOG_DIR}" \
  "${HADOOP_PID_DIR}" \
  "${YARN_LOG_DIR}"

until nc -z master 9000; do
  sleep 2
done

nohup "${HADOOP_HOME}/bin/hdfs" datanode \
  >> "${HADOOP_LOG_DIR}/datanode-${WORKER_NAME}-console.log" 2>&1 &

nohup "${HADOOP_HOME}/bin/yarn" nodemanager \
  >> "${YARN_LOG_DIR}/nodemanager-${WORKER_NAME}-console.log" 2>&1 &

if [[ "${ENABLE_SPARK:-false}" == "true" ]]; then
  if [[ ! -x "${SPARK_HOME}/sbin/start-worker.sh" ]]; then
    echo "Spark no esta instalado en la imagen actual (${SPARK_HOME}/sbin/start-worker.sh)." >&2
    exit 1
  fi

  mkdir -p "${SPARK_LOG_DIR}"
  "${SPARK_HOME}/sbin/start-worker.sh" \
    --webui-port "${SPARK_WORKER_WEBUI_PORT}" \
    "spark://master:7077"
fi

if [[ "${ENABLE_CASSANDRA:-false}" == "true" ]]; then
  if [[ ! -x "/opt/bigdata/bin/start-cassandra.sh" ]]; then
    echo "Cassandra no esta instalado en la imagen actual." >&2
    exit 1
  fi
  /opt/bigdata/bin/start-cassandra.sh
fi

echo "${WORKER_NAME} ready"
jps > "${BIGDATA_HOME}/logs/runtime-${WORKER_NAME}.log" 2>&1 || true
exec /bin/bash -lc "while true; do sleep 3600; done"
