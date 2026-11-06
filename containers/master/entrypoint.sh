#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

export BIGDATA_HOME="${BIGDATA_HOME:-/opt/bigdata}"
export HADOOP_HOME="${HADOOP_HOME:-/opt/bigdata/hadoop}"
export PIG_HOME="${PIG_HOME:-/opt/bigdata/pig}"
export HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-/opt/bigdata/conf/hadoop}"
export PIG_CONF_DIR="${PIG_CONF_DIR:-/opt/bigdata/conf/pig}"
export HADOOP_LOG_DIR="${HADOOP_LOG_DIR:-/opt/bigdata/logs/hadoop}"
export HADOOP_PID_DIR="${HADOOP_PID_DIR:-/opt/bigdata/logs/hadoop/pids}"
export YARN_LOG_DIR="${YARN_LOG_DIR:-/opt/bigdata/logs/yarn}"
export JAVA_HOME="${JAVA_HOME:-/opt/java/openjdk}"
export SPARK_HOME="${SPARK_HOME:-/opt/bigdata/spark}"
export SPARK_CONF_DIR="${SPARK_CONF_DIR:-/opt/bigdata/conf/spark}"
export SPARK_LOG_DIR="${SPARK_LOG_DIR:-/opt/bigdata/logs/spark}"

mkdir -p \
  "${BIGDATA_HOME}/data/namenode" \
  "${BIGDATA_HOME}/data/shared" \
  "${BIGDATA_HOME}/data/outputs" \
  "${HADOOP_LOG_DIR}" \
  "${HADOOP_PID_DIR}" \
  "${YARN_LOG_DIR}"

VERSION_FILE="${BIGDATA_HOME}/data/namenode/current/VERSION"
if [[ ! -f "${VERSION_FILE}" ]]; then
  "${HADOOP_HOME}/bin/hdfs" namenode -format -force -nonInteractive
fi

nohup "${HADOOP_HOME}/bin/hdfs" namenode \
  >> "${HADOOP_LOG_DIR}/namenode-console.log" 2>&1 &

nohup "${HADOOP_HOME}/bin/yarn" resourcemanager \
  >> "${YARN_LOG_DIR}/resourcemanager-console.log" 2>&1 &

nohup "${HADOOP_HOME}/bin/mapred" historyserver \
  >> "${YARN_LOG_DIR}/historyserver-console.log" 2>&1 &

if [[ "${ENABLE_SPARK:-false}" == "true" ]]; then
  if [[ ! -x "${SPARK_HOME}/sbin/start-master.sh" ]]; then
    echo "Spark no esta instalado en la imagen actual (${SPARK_HOME}/sbin/start-master.sh)." >&2
    exit 1
  fi

  mkdir -p "${SPARK_LOG_DIR}"
  "${SPARK_HOME}/sbin/start-master.sh" \
    --host master \
    --port 7077 \
    --webui-port 8080
fi

if [[ "${ENABLE_CASSANDRA:-false}" == "true" ]]; then
  if [[ ! -x "/opt/bigdata/bin/start-cassandra.sh" ]]; then
    echo "Cassandra no esta instalado en la imagen actual." >&2
    exit 1
  fi
  /opt/bigdata/bin/start-cassandra.sh
fi

echo "master ready"
jps > "${BIGDATA_HOME}/logs/runtime-master.log" 2>&1 || true
exec /bin/bash -lc "while true; do sleep 3600; done"
