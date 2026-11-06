#!/usr/bin/env bash
# Compila y ejecuta la indexacion de lab05 sobre el overlay IR.
set -euo pipefail

podman_bin="$(command -v podman || true)"
[[ -n "$podman_bin" ]] || { echo "podman no esta disponible en PATH." >&2; exit 1; }

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
input_local_path="${INPUT_LOCAL_PATH:-/opt/bigdata/data/shared/lab05/datasets/es-wiki-articles-1k.tsv.gz}"
index_name="${INDEX_NAME:-wiki-lab05}"
project_dir="$root/data/shared/lab05/work/gdd-elastic"
build_file="$project_dir/build.xml"
host_dataset_path="$root/data/shared/lab05/datasets/es-wiki-articles-1k.tsv.gz"
timestamp="$(date +%Y%m%d-%H%M%S)"
run_id="${timestamp}-lab05-index"

if [[ ! -f "$build_file" ]]; then
  "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/prepare-lab05.sh"
fi

if [[ ! -f "$build_file" ]]; then
  echo "No se encontro el proyecto preparado de lab05 en $project_dir" >&2
  exit 1
fi

if [[ "$input_local_path" == "/opt/bigdata/data/shared/lab05/datasets/es-wiki-articles-1k.tsv.gz" && ! -f "$host_dataset_path" ]]; then
  echo "No se encontro el dataset local esperado: $host_dataset_path" >&2
  exit 1
fi

"$podman_bin" exec bigdata-master /bin/bash -lc "
set -euo pipefail
workdir='/tmp/$run_id'
rm -rf \"\$workdir\"
mkdir -p \"\$workdir\"
cp -R /opt/bigdata/data/shared/lab05/work/gdd-elastic \"\$workdir/\"
cd \"\$workdir/gdd-elastic\"
rm -rf bin dist stage
mkdir -p bin dist stage/META-INF
javac -cp 'lib/*' -d bin \$(find src -name '*.java')
cp -R bin/* stage/
cp -R meta/* stage/META-INF/
for dep in lib/*.jar; do
  (
    cd stage
    jar xf \"../\$dep\"
  )
done
jar cfm dist/gdd-elastic.jar meta/MANIFEST.MF -C stage .
java -jar dist/gdd-elastic.jar BuildWikiIndexBulk -i '$input_local_path' -igz -o '$index_name'
"

echo "Indexacion solicitada para el indice: $index_name"
echo "Indexacion completada con el empaquetado jar requerido por el proyecto de lab05."
