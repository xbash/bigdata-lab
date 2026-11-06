#!/usr/bin/env bash

set -uo pipefail

fail() {
    echo "ERROR: $*" >&2
    exit 1
}

normalize_n_values() {
    local input_values=("$@")
    local normalized_values=()
    local item
    local part

    for item in "${input_values[@]}"; do
        item="${item//,/ }"
        for part in $item; do
            if [[ -z "$part" ]]; then
                continue
            fi
            if [[ ! "$part" =~ ^[0-9]+$ ]]; then
                fail "Valor invalido para -NValues: '$part'. Usa enteros separados por coma o espacio, por ejemplo -NValues 2,3,4."
            fi
            normalized_values+=("$part")
        done
    done

    if [[ ${#normalized_values[@]} -eq 0 ]]; then
        fail "Debes indicar al menos un valor entero en -NValues."
    fi

    N_VALUES=("${normalized_values[@]}")
}

validate_integer() {
    local name="$1"
    local value="$2"
    if [[ ! "$value" =~ ^[0-9]+$ ]]; then
        fail "$name debe ser un entero no negativo: '$value'."
    fi
}

lab01_init_context() {
    local script_dir="$1"

    ROOT_DIR="$(cd "$script_dir/.." && pwd)"
    DATA_DIR="$ROOT_DIR/datasets"
    WORK_ROOT_DIR="$ROOT_DIR/work"
    PROJECT_DIR="$WORK_ROOT_DIR/gdd_lab01/gdd-wiki"
    RESULT_DIR="$ROOT_DIR/results"
    LOG_DIR="$ROOT_DIR/logs"
    SUMMARY_CSV="$LOG_DIR/runs_summary.csv"

    if [[ "$USE_SAMPLE" == true ]]; then
        INPUT_PATH="$DATA_DIR/es-wiki-abstracts-1k.txt"
        INPUT_IS_GZIP=false
        INPUT_LABEL="sample-1k"
    else
        INPUT_PATH="$DATA_DIR/es-wiki-abstracts.txt.gz"
        INPUT_IS_GZIP=true
        INPUT_LABEL="full-gzip"
    fi

    if [[ -n "$JAVA_HOME_OVERRIDE" ]]; then
        JAVA_EXE="$JAVA_HOME_OVERRIDE/bin/java"
    elif [[ -n "${JAVA_HOME:-}" && -x "${JAVA_HOME:-}/bin/java" ]]; then
        JAVA_EXE="$JAVA_HOME/bin/java"
    else
        JAVA_EXE="$(command -v java || true)"
    fi

    [[ -n "$JAVA_EXE" && -x "$JAVA_EXE" ]] || fail "No se encontro Java. Instala JDK 21 o usa -JavaHome /ruta/del/jdk."
    [[ -f "$INPUT_PATH" ]] || fail "No se encontro el archivo de entrada: $INPUT_PATH"
    [[ -d "$PROJECT_DIR" ]] || fail "No se encontro el proyecto Java: $PROJECT_DIR"

    mkdir -p "$RESULT_DIR" "$LOG_DIR"

    result_write_probe="$RESULT_DIR/codex-write-probe.tmp"
    printf 'probe\n' > "$result_write_probe" 2>/dev/null || fail "No se pudo escribir en '$RESULT_DIR'. El laboratorio esta configurado para dejar todos los resultados en ese directorio; corrige permisos antes de ejecutar."
    rm -f "$result_write_probe"

    log_write_probe="$LOG_DIR/codex-write-probe.tmp"
    printf 'probe\n' > "$log_write_probe" 2>/dev/null || fail "No se pudo escribir en '$LOG_DIR'. El laboratorio esta configurado para dejar todas las trazas y evidencias en ese directorio; corrige permisos antes de ejecutar."
    rm -f "$log_write_probe"

    ACTIVE_RESULT_DIR="$RESULT_DIR"

    if [[ ! -f "$SUMMARY_CSV" ]]; then
        printf '%s\n' 'timestamp,name,input,heap,exit_code,elapsed_seconds,stdout,stderr,args' > "$SUMMARY_CSV"
    fi

    CLASSPATH="bin:lib/commons-cli-1.1.jar"
    MAIN_CLASS="org.mdp.cli.Main"
}

csv_field() {
    local value="${1:-}"
    value="${value//\"/\"\"}"
    printf '"%s"' "$value"
}

append_csv_row() {
    local first=true
    local value
    for value in "$@"; do
        if [[ "$first" == true ]]; then
            first=false
        else
            printf ','
        fi
        csv_field "$value"
    done
    printf '\n'
}

run_path_stdout() { printf '%s/%s.stdout.txt' "$LOG_DIR" "$1"; }
run_path_stderr() { printf '%s/%s.stderr.log' "$LOG_DIR" "$1"; }
run_path_meta() { printf '%s/%s.meta.txt' "$LOG_DIR" "$1"; }
run_path_done() { printf '%s/%s.done' "$LOG_DIR" "$1"; }

command_text() {
    local args=("$@")
    local out=""
    local arg
    for arg in "${args[@]}"; do
        if [[ -n "$out" ]]; then
            out+=" "
        fi
        printf -v quoted '%q' "$arg"
        out+="$quoted"
    done
    printf '%s' "$out"
}

timestamp() {
    date '+%Y-%m-%dT%H:%M:%S'
}

now_millis() {
    perl -MTime::HiRes=time -e 'printf "%.0f\n", time() * 1000'
}

elapsed_seconds() {
    local start_ms="$1"
    local end_ms="$2"
    awk -v start="$start_ms" -v end="$end_ms" 'BEGIN { printf "%.3f", (end - start) / 1000 }'
}

write_metadata() {
    local name="$1"
    local stdout_path="$2"
    local stderr_path="$3"
    shift 3
    local all_args=("$@")

    {
        printf '%s\n' '# Lab01 run metadata'
        printf 'timestamp_start=%s\n' "$(timestamp)"
        printf 'name=%s\n' "$name"
        printf 'java=%s\n' "$JAVA_EXE"
        printf 'heap=-Xmx%s\n' "$HEAP"
        printf 'input_label=%s\n' "$INPUT_LABEL"
        printf 'input_path=%s\n' "$INPUT_PATH"
        printf 'top_k=%s\n' "$TOP_K"
        printf 'batch_size=%s\n' "$BATCH_SIZE"
        printf 'project_dir=%s\n' "$PROJECT_DIR"
        printf 'result_dir=%s\n' "$ACTIVE_RESULT_DIR"
        printf 'stdout=%s\n' "$stdout_path"
        printf 'stderr=%s\n' "$stderr_path"
        printf 'command=%s\n' "$(command_text "${all_args[@]}")"
        printf '\n'
    }
}

invoke_lab_java() {
    local name="$1"
    shift
    local program_args=("$@")
    local stdout_path stderr_path meta_path done_path raw_stderr
    stdout_path="$(run_path_stdout "$name")"
    stderr_path="$(run_path_stderr "$name")"
    meta_path="$(run_path_meta "$name")"
    done_path="$(run_path_done "$name")"
    raw_stderr="$LOG_DIR/$name.stderr.raw.tmp"

    if [[ -f "$done_path" && "$FORCE" != true ]]; then
        echo "[SKIP] $name ya tiene marcador .done. Usa -Force para repetir."
        return 0
    fi

    echo "[RUN ] $name"
    echo "       args: $(command_text "${program_args[@]}")"

    local all_args=("-Xmx$HEAP" "-cp" "$CLASSPATH" "$MAIN_CLASS" "${program_args[@]}")
    write_metadata "$name" "$stdout_path" "$stderr_path" "${all_args[@]}" > "$meta_path"
    cp "$meta_path" "$stderr_path"
    rm -f "$raw_stderr"

    local start_ms end_ms elapsed exit_code arg_text
    start_ms="$(now_millis)"
    (
        cd "$PROJECT_DIR" || exit 125
        "$JAVA_EXE" "${all_args[@]}"
    ) > "$stdout_path" 2> "$raw_stderr"
    exit_code=$?
    end_ms="$(now_millis)"
    elapsed="$(elapsed_seconds "$start_ms" "$end_ms")"

    if [[ -s "$raw_stderr" ]]; then
        cat "$raw_stderr" >> "$stderr_path"
    fi
    rm -f "$raw_stderr"

    arg_text="$(command_text "${all_args[@]}")"
    append_csv_row \
        "$(timestamp)" \
        "$name" \
        "$INPUT_LABEL" \
        "$HEAP" \
        "$exit_code" \
        "$elapsed" \
        "$stdout_path" \
        "$stderr_path" \
        "$arg_text" >> "$SUMMARY_CSV"

    if [[ "$exit_code" -eq 0 ]]; then
        printf 'completed %s\n' "$(timestamp)" > "$done_path"
        echo "[ OK ] $name en $elapsed segundos"
    else
        echo "[FAIL] $name termino con codigo $exit_code en $elapsed segundos"
        echo "       Revisa: $stderr_path"
    fi
}

show_lab01_run_header() {
    local mode_label="$1"
    echo "== Lab01 $mode_label =="
    echo "Java: $JAVA_EXE"
    echo "Heap: -Xmx$HEAP"
    echo "Data: $DATA_DIR"
    echo "Project: $PROJECT_DIR"
    echo "Input: $INPUT_PATH"
    echo "Logs: $LOG_DIR"
    echo "Results: $ACTIVE_RESULT_DIR"
    echo "Summary: $SUMMARY_CSV"
}

invoke_lab01_inmemory() {
    show_lab01_run_header "in-memory"

    local word_args=("RunWordCountInMemory" "-i" "$INPUT_PATH")
    if [[ "$INPUT_IS_GZIP" == true ]]; then
        word_args+=("-igz")
    fi
    word_args+=("-k" "$TOP_K")
    invoke_lab_java "wordcount_${INPUT_LABEL}_top$TOP_K" "${word_args[@]}"

    local n
    for n in "${N_VALUES[@]}"; do
        local ngram_args=("RunNGramCountInMemory" "-i" "$INPUT_PATH")
        if [[ "$INPUT_IS_GZIP" == true ]]; then
            ngram_args+=("-igz")
        fi
        ngram_args+=("-k" "$TOP_K" "-n" "$n")
        invoke_lab_java "ngram_inmemory_${INPUT_LABEL}_n${n}_top$TOP_K" "${ngram_args[@]}"
    done

    echo "== Terminado =="
    echo "Resumen CSV: $SUMMARY_CSV"
}

invoke_lab01_external() {
    show_lab01_run_header "external"

    local suffix="n$EXTERNAL_N"
    local ngrams sorted counted ranked top_file tmp_dir
    if [[ "$INPUT_IS_GZIP" == true ]]; then
        ngrams="$ACTIVE_RESULT_DIR/es-wiki-abstracts-$suffix-grams.txt.gz"
        sorted="$ACTIVE_RESULT_DIR/es-wiki-abstracts-$suffix-grams-s.txt.gz"
        counted="$ACTIVE_RESULT_DIR/es-wiki-abstracts-$suffix-grams-c.txt.gz"
        ranked="$ACTIVE_RESULT_DIR/es-wiki-abstracts-$suffix-grams-c-s.txt.gz"
    else
        ngrams="$ACTIVE_RESULT_DIR/es-wiki-abstracts-$suffix-grams.txt"
        sorted="$ACTIVE_RESULT_DIR/es-wiki-abstracts-$suffix-grams-s.txt"
        counted="$ACTIVE_RESULT_DIR/es-wiki-abstracts-$suffix-grams-c.txt"
        ranked="$ACTIVE_RESULT_DIR/es-wiki-abstracts-$suffix-grams-c-s.txt"
    fi
    top_file="$ACTIVE_RESULT_DIR/es-wiki-abstracts-$suffix-grams-c-s-top$TOP_K.txt"
    tmp_dir="$ACTIVE_RESULT_DIR/tmp"
    mkdir -p "$tmp_dir"

    local extract_args=("ExtractNGrams" "-i" "$INPUT_PATH")
    if [[ "$INPUT_IS_GZIP" == true ]]; then
        extract_args+=("-igz")
    fi
    extract_args+=("-n" "$EXTERNAL_N" "-o" "$ngrams")
    if [[ "$INPUT_IS_GZIP" == true ]]; then
        extract_args+=("-ogz")
    fi
    invoke_lab_java "external_01_extract_${INPUT_LABEL}_$suffix" "${extract_args[@]}"

    local sort_args=("ExternalMergeSort" "-i" "$ngrams")
    if [[ "$INPUT_IS_GZIP" == true ]]; then
        sort_args+=("-igz")
    fi
    sort_args+=("-o" "$sorted")
    if [[ "$INPUT_IS_GZIP" == true ]]; then
        sort_args+=("-ogz")
    fi
    sort_args+=("-tmp" "$tmp_dir" "-b" "$BATCH_SIZE")
    invoke_lab_java "external_02_sort_${INPUT_LABEL}_${suffix}_b$BATCH_SIZE" "${sort_args[@]}"

    local count_args=("CountDuplicates" "-i" "$sorted")
    if [[ "$INPUT_IS_GZIP" == true ]]; then
        count_args+=("-igz")
    fi
    count_args+=("-o" "$counted")
    if [[ "$INPUT_IS_GZIP" == true ]]; then
        count_args+=("-ogz")
    fi
    invoke_lab_java "external_03_count_${INPUT_LABEL}_$suffix" "${count_args[@]}"

    local rank_args=("ExternalMergeSort" "-i" "$counted")
    if [[ "$INPUT_IS_GZIP" == true ]]; then
        rank_args+=("-igz")
    fi
    rank_args+=("-o" "$ranked")
    if [[ "$INPUT_IS_GZIP" == true ]]; then
        rank_args+=("-ogz")
    fi
    rank_args+=("-tmp" "$tmp_dir" "-b" "$BATCH_SIZE" "-r")
    invoke_lab_java "external_04_rank_${INPUT_LABEL}_${suffix}_b$BATCH_SIZE" "${rank_args[@]}"

    local head_args=("Head" "-i" "$ranked")
    if [[ "$INPUT_IS_GZIP" == true ]]; then
        head_args+=("-igz")
    fi
    head_args+=("-k" "$TOP_K" "-o" "$top_file")
    invoke_lab_java "external_05_head_${INPUT_LABEL}_${suffix}_top$TOP_K" "${head_args[@]}"

    echo "Top-$TOP_K esperado en: $top_file"
    echo "== Terminado =="
    echo "Resumen CSV: $SUMMARY_CSV"
}
