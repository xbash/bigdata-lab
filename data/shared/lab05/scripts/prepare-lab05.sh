#!/usr/bin/env bash
# Extrae el proyecto fuente de lab05 desde el ZIP del curso.
set -euo pipefail

force="${1:-}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
zip_path="$root/data/shared/lab05/docs/gdd_lab05.zip"
work_dir="$root/data/shared/lab05/work"
project_dir="$work_dir/gdd-elastic"

command -v python3 >/dev/null 2>&1 || { echo "python3 no esta disponible en PATH." >&2; exit 1; }

if [[ "$force" != "" && "$force" != "--force" ]]; then
  echo "Uso: $(basename "$0") [--force]" >&2
  exit 1
fi

if [[ ! -f "$zip_path" ]]; then
  echo "No se encontro el ZIP requerido del laboratorio: $zip_path" >&2
  exit 1
fi

if [[ -d "$project_dir" && "$force" != "--force" ]]; then
  echo "Proyecto ya extraido en $project_dir"
  echo "Use --force si quiere recrearlo desde el ZIP."
  exit 0
fi

rm -rf "$work_dir"
mkdir -p "$work_dir"
python3 - "$zip_path" "$work_dir" <<'PY'
import sys
import zipfile

zip_path = sys.argv[1]
work_dir = sys.argv[2]

with zipfile.ZipFile(zip_path) as zf:
    zf.extractall(work_dir)
PY

echo "Proyecto de lab05 extraido en $project_dir"
echo "Dataset de muestra esperado: data/shared/lab05/datasets/es-wiki-articles-1k.tsv.gz"
