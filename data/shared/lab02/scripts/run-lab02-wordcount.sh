#!/usr/bin/env bash
# Compila y ejecuta el WordCount de lab02 sobre HDFS local.
set -euo pipefail

podman_bin="$(command -v podman || true)"
[[ -n "$podman_bin" ]] || { echo "podman no esta disponible en PATH." >&2; exit 1; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
WORK_PROJECT_PATH="$ROOT_DIR/data/shared/lab02/work/gdd-hadoop"
LOGS_DIR="$ROOT_DIR/data/shared/lab02/logs"

INPUT_LOCAL_PATH="${INPUT_LOCAL_PATH:-/opt/bigdata/data/shared/lab01/datasets/es-wiki-abstracts.txt.gz}"
INPUT_HDFS_PATH="${INPUT_HDFS_PATH:-/inputs/lab02/es-wiki-abstracts.txt.gz}"
OUTPUT_HDFS_ROOT="${OUTPUT_HDFS_ROOT:-/outputs/lab02}"
timestamp="$(date +%Y%m%d-%H%M%S)"
output_hdfs_path="${OUTPUT_HDFS_ROOT%/}/wordcount-${timestamp}"
run_log_path="$LOGS_DIR/${timestamp}-wordcount-run.log"
top20_path="$LOGS_DIR/${timestamp}-wordcount-top20.txt"
container_project_path="/opt/bigdata/data/shared/lab02/work/gdd-hadoop"

[[ -d "$WORK_PROJECT_PATH" ]] || { echo "No se encontro el proyecto de trabajo requerido: $WORK_PROJECT_PATH" >&2; exit 1; }
[[ -f "$WORK_PROJECT_PATH/src/org/mdp/hadoop/cli/WordCount.java" ]] || { echo "No se encontro WordCount.java en el arbol de trabajo: $WORK_PROJECT_PATH" >&2; exit 1; }
[[ -f "$WORK_PROJECT_PATH/src/org/mdp/hadoop/cli/LetterCount.java" ]] || { echo "No se encontro LetterCount.java en el arbol de trabajo: $WORK_PROJECT_PATH" >&2; exit 1; }

mkdir -p "$LOGS_DIR"

read -r -d '' compile_command <<EOF || true
set -euo pipefail
cd "${container_project_path}"
test -f src/org/mdp/hadoop/cli/Main.java
test -f src/org/mdp/hadoop/cli/WordCount.java
test -f src/org/mdp/hadoop/cli/LetterCount.java
rm -rf bin dist
mkdir -p bin dist
javac -cp "\$(hadoop classpath)" -d bin \
  src/org/mdp/hadoop/cli/Main.java \
  src/org/mdp/hadoop/cli/WordCount.java \
  src/org/mdp/hadoop/cli/LetterCount.java
jar cfe dist/gdd-hadoop.jar org.mdp.hadoop.cli.Main -C bin .
hdfs dfs -mkdir -p /inputs/lab02
hdfs dfs -put -f "${INPUT_LOCAL_PATH}" "${INPUT_HDFS_PATH}"
hdfs dfs -rm -r -f "${output_hdfs_path}" >/dev/null 2>&1 || true
hadoop jar dist/gdd-hadoop.jar WordCount "${INPUT_HDFS_PATH}" "${output_hdfs_path}"
echo ---WORDCOUNT-TOP20-BEGIN---
hdfs dfs -text "${output_hdfs_path}/part-r-00000" | awk 'NR <= 20 { print }'
echo ---WORDCOUNT-TOP20-END---
echo ---WORDCOUNT-OUTPUT---
echo "${output_hdfs_path}"
EOF

raw_output="$("$podman_bin" exec bigdata-master /bin/bash -lc "${compile_command}" 2>&1)"
printf '%s\n' "$raw_output" | tee "$run_log_path"

printf '%s\n' "$raw_output" | awk '
  /---WORDCOUNT-TOP20-BEGIN---/ { capture=1; next }
  /---WORDCOUNT-TOP20-END---/ { capture=0; next }
  capture { print }
' > "$top20_path"

printf 'Resultado HDFS: %s\n' "$output_hdfs_path"
printf 'Log local: %s\n' "$run_log_path"
printf 'Top20 local: %s\n' "$top20_path"
