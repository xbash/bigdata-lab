#!/usr/bin/env bash
# Compila y ejecuta una consulta de busqueda de lab05 sobre el overlay IR.
set -euo pipefail

podman_bin="$(command -v podman || true)"
[[ -n "$podman_bin" ]] || { echo "podman no esta disponible en PATH." >&2; exit 1; }
command -v base64 >/dev/null 2>&1 || { echo "base64 no esta disponible en PATH." >&2; exit 1; }

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
index_name="${INDEX_NAME:-wiki-lab05}"
query_text="${QUERY_TEXT:-linux}"
timeout_sec="${TIMEOUT_SEC:-10}"
project_dir="$root/data/shared/lab05/work/gdd-elastic"
build_file="$project_dir/build.xml"
timestamp="$(date +%Y%m%d-%H%M%S)"
run_id="${timestamp}-lab05-search"
query_b64="$(printf '%s' "$query_text" | base64 | tr -d '\r\n')"

if [[ ! -f "$build_file" ]]; then
  "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/prepare-lab05.sh"
fi

if [[ ! -f "$build_file" ]]; then
  echo "No se encontro el proyecto preparado de lab05 en $project_dir" >&2
  exit 1
fi

set +e
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
set +e
query_text=\$(printf '%s' '$query_b64' | base64 -d)
printf '%s\n' \"\$query_text\" | timeout '${timeout_sec}'s java -jar dist/gdd-elastic.jar SearchWikiIndex -i '$index_name'
status=\$?
set -e
if [ \"\$status\" -ne 0 ] && [ \"\$status\" -ne 124 ]; then
  exit \"\$status\"
fi
"
status=$?
set -e

if [[ "$status" -ne 0 ]]; then
  exit "$status"
fi

echo "Busqueda solicitada en el indice: $index_name"
echo "ADVERTENCIA: la busqueda se ejecuta con timeout porque la aplicacion del curso entra en un loop interactivo." >&2
echo "Busqueda ejecutada con la salida funcional de titulo, url y abstract."
