#!/usr/bin/env bash
# Compila y ejecuta el LetterCount de lab02 sobre HDFS local,
# usando como entrada la salida previa de WordCount.
set -euo pipefail

podman_bin="$(command -v podman || true)"
[[ -n "$podman_bin" ]] || { echo "podman no esta disponible en PATH." >&2; exit 1; }

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
WORK_PROJECT_PATH="$ROOT_DIR/data/shared/lab02/work/gdd-hadoop"
LOGS_DIR="$ROOT_DIR/data/shared/lab02/logs"
RESULTS_DIR="$ROOT_DIR/data/shared/lab02/results"

WORDCOUNT_INPUT_HDFS_PATH="${WORDCOUNT_INPUT_HDFS_PATH:-}"
OUTPUT_HDFS_ROOT="${OUTPUT_HDFS_ROOT:-/outputs/lab02}"
timestamp="$(date +%Y%m%d-%H%M%S)"
output_hdfs_path="${OUTPUT_HDFS_ROOT%/}/lettercount-${timestamp}"
run_log_path="$LOGS_DIR/${timestamp}-lettercount-run.log"
az_path="$RESULTS_DIR/${timestamp}-lettercount-a-z.txt"
container_project_path="/opt/bigdata/data/shared/lab02/work/gdd-hadoop"

[[ -n "$WORDCOUNT_INPUT_HDFS_PATH" ]] || { echo "Debes definir WORDCOUNT_INPUT_HDFS_PATH con la carpeta HDFS de salida de WordCount." >&2; exit 1; }
[[ -d "$WORK_PROJECT_PATH" ]] || { echo "No se encontro el proyecto de trabajo requerido: $WORK_PROJECT_PATH" >&2; exit 1; }
[[ -f "$WORK_PROJECT_PATH/src/org/mdp/hadoop/cli/WordCount.java" ]] || { echo "No se encontro WordCount.java en el arbol de trabajo: $WORK_PROJECT_PATH" >&2; exit 1; }
[[ -f "$WORK_PROJECT_PATH/src/org/mdp/hadoop/cli/LetterCount.java" ]] || { echo "No se encontro LetterCount.java en el arbol de trabajo: $WORK_PROJECT_PATH" >&2; exit 1; }

mkdir -p "$LOGS_DIR" "$RESULTS_DIR"

read -r -d '' compile_command <<EOF || true
set -euo pipefail
cd "${container_project_path}"
test -f src/org/mdp/hadoop/cli/Main.java
test -f src/org/mdp/hadoop/cli/WordCount.java
test -f src/org/mdp/hadoop/cli/LetterCount.java
hdfs dfs -test -e "${WORDCOUNT_INPUT_HDFS_PATH}"
rm -rf bin dist
mkdir -p bin dist
javac -cp "\$(hadoop classpath)" -d bin \
  src/org/mdp/hadoop/cli/Main.java \
  src/org/mdp/hadoop/cli/WordCount.java \
  src/org/mdp/hadoop/cli/LetterCount.java
jar cfe dist/gdd-hadoop.jar org.mdp.hadoop.cli.Main -C bin .
hdfs dfs -rm -r -f "${output_hdfs_path}" >/dev/null 2>&1 || true
hadoop jar dist/gdd-hadoop.jar LetterCount "${WORDCOUNT_INPUT_HDFS_PATH}" "${output_hdfs_path}"
echo ---LETTERCOUNT-AZ-BEGIN---
hdfs dfs -text "${output_hdfs_path}/part-r-00000" | awk -F '\t' '\$1 ~ /^[a-z]\$/ { print }' | sort | awk 'NR <= 26 { print }'
echo ---LETTERCOUNT-AZ-END---
echo ---LETTERCOUNT-OUTPUT---
echo "${output_hdfs_path}"
EOF

raw_output="$("$podman_bin" exec bigdata-master /bin/bash -lc "${compile_command}" 2>&1)"
printf '%s\n' "$raw_output" | tee "$run_log_path"

printf '%s\n' "$raw_output" | awk '
  /---LETTERCOUNT-AZ-BEGIN---/ { capture=1; next }
  /---LETTERCOUNT-AZ-END---/ { capture=0; next }
  capture { print }
' > "$az_path"

printf 'Resultado HDFS: %s\n' "$output_hdfs_path"
printf 'Log local: %s\n' "$run_log_path"
printf 'Resultados a-z locales: %s\n' "$az_path"
