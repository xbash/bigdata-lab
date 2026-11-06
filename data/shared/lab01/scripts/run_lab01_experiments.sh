#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/run_lab01_common.sh"

JAVA_HOME_OVERRIDE=""
HEAP="4096M"
N_VALUES=("2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12")
TOP_K=100
BATCH_SIZE=500000
EXTERNAL_N=12
MODE="Both"
RUN_EXTERNAL_PIPELINE=false
SKIP_IN_MEMORY=false
USE_SAMPLE=false
FORCE=false

usage() {
    cat <<'EOF'
Uso:
  bash scripts/run_lab01_experiments.sh [opciones]

Opciones compatibles con el script PowerShell:
  -JavaHome PATH              Ruta del JDK; debe contener bin/java.
  -Heap VALUE                 Heap JVM, por ejemplo 4096M, 8G, 28G.
  -NValues VALUES             N-gramas en memoria, separados por coma o espacio.
  -TopK N                     Cantidad de resultados top-k.
  -BatchSize N                Tamano de lote para ExternalMergeSort.
  -ExternalN N                Valor n para el pipeline externo.
  -Mode VALUE                 Modo oficial: InMemory, External o Both.
  -RunExternalPipeline        Compatibilidad legacy. Preferir -Mode.
  -SkipInMemory               Compatibilidad legacy. Preferir -Mode.
  -UseSample                  Usa datasets/es-wiki-abstracts-1k.txt.
  -Force                      Repite corridas aunque exista marcador .done.
  -h, --help                  Muestra esta ayuda.

Ejemplos:
  bash scripts/run_lab01_experiments.sh -Mode InMemory -UseSample -NValues 2 -TopK 5 -Heap 1024M
  bash scripts/run_lab01_experiments.sh -Mode InMemory -NValues 2,3,4,5,6,7,8,9,10 -TopK 100 -Heap 4096M
  bash scripts/run_lab01_experiments.sh -Mode External -ExternalN 50 -Heap 8G -BatchSize 500000 -TopK 100
  bash scripts/run_lab01_experiments.sh -Mode Both -UseSample -NValues 2,3 -ExternalN 12 -TopK 20 -Heap 1024M
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -JavaHome|--java-home)
            [[ $# -ge 2 ]] || fail "Falta valor para $1."
            JAVA_HOME_OVERRIDE="$2"
            shift 2
            ;;
        -Heap|--heap)
            [[ $# -ge 2 ]] || fail "Falta valor para $1."
            HEAP="$2"
            shift 2
            ;;
        -NValues|--n-values)
            shift
            values=()
            while [[ $# -gt 0 && "$1" != -* ]]; do
                values+=("$1")
                shift
            done
            normalize_n_values "${values[@]}"
            ;;
        -TopK|--top-k)
            [[ $# -ge 2 ]] || fail "Falta valor para $1."
            TOP_K="$2"
            validate_integer "TopK" "$TOP_K"
            shift 2
            ;;
        -BatchSize|--batch-size)
            [[ $# -ge 2 ]] || fail "Falta valor para $1."
            BATCH_SIZE="$2"
            validate_integer "BatchSize" "$BATCH_SIZE"
            shift 2
            ;;
        -ExternalN|--external-n)
            [[ $# -ge 2 ]] || fail "Falta valor para $1."
            EXTERNAL_N="$2"
            validate_integer "ExternalN" "$EXTERNAL_N"
            shift 2
            ;;
        -Mode|--mode)
            [[ $# -ge 2 ]] || fail "Falta valor para $1."
            MODE="$2"
            case "$MODE" in
                InMemory|External|Both)
                    ;;
                *)
                    fail "Valor invalido para -Mode: '$MODE'. Usa InMemory, External o Both."
                    ;;
            esac
            shift 2
            ;;
        -RunExternalPipeline|--run-external-pipeline)
            RUN_EXTERNAL_PIPELINE=true
            shift
            ;;
        -SkipInMemory|--skip-in-memory)
            SKIP_IN_MEMORY=true
            shift
            ;;
        -UseSample|--use-sample)
            USE_SAMPLE=true
            shift
            ;;
        -Force|--force)
            FORCE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            fail "Opcion no reconocida: $1"
            ;;
    esac
done

if [[ "$RUN_EXTERNAL_PIPELINE" == true || "$SKIP_IN_MEMORY" == true ]]; then
    if [[ "$SKIP_IN_MEMORY" != true && "$RUN_EXTERNAL_PIPELINE" == true ]]; then
        MODE="Both"
    elif [[ "$SKIP_IN_MEMORY" == true && "$RUN_EXTERNAL_PIPELINE" == true ]]; then
        MODE="External"
    elif [[ "$SKIP_IN_MEMORY" != true && "$RUN_EXTERNAL_PIPELINE" != true ]]; then
        MODE="InMemory"
    else
        fail "La combinacion -SkipInMemory sin -RunExternalPipeline ya no es valida. Usa -Mode InMemory, -Mode External o -Mode Both."
    fi
fi

lab01_init_context "$SCRIPT_DIR"
show_lab01_run_header "experiments"

if [[ "$MODE" == "InMemory" || "$MODE" == "Both" ]]; then
    invoke_lab01_inmemory
fi

if [[ "$MODE" == "External" || "$MODE" == "Both" ]]; then
    invoke_lab01_external
fi
