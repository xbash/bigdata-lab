# PLAN — Consolidación documental, VERSION única, lab08 y cierre de v0.4.1

Fecha: 2026-10-22 (revisión 2 tras los comentarios del usuario). Solo planificación: ninguna acción fue ejecutada.
Estado global: **NOT_READY_FOR_EXECUTION** (hay acciones READY, pero PC-14 está BLOCKED y varias requieren confirmación).

## 1. Requerimiento

1. Eliminar `CONTEXTO_PROYECTO.md`, `DECISIONES_TECNICAS.md` y `PENDIENTES.md` (**autorizado por el usuario el 2026-10-22**).
2. Crear `VERSION` como fuente única de la versión del proyecto y retirar de los demás archivos cualquier referencia a release o versión del proyecto.
3. `VERSION` debe contener `v0.4.1`.
4. Commitear `AGENTS.md` y la documentación, reconciliar lab08/MongoDB, validar wrappers `bash` y cerrar la versión.
5. Reemplazar los modelos Luna/Tierra por roles de Claude (hoy se trabaja con Claude):
   - **Ejecutor** (económico): tareas mecánicas ya especificadas.
   - **Planificador**: planes, análisis, causa raíz y diagnóstico de fallos.
   - **Superior**: diseño y estrategia ante decisiones nuevas.
   - Mapeo sugerido, no aplicado: Ejecutor = Haiku 5.5, Planificador = Sonnet 5.5, Superior = Opus 5.5 o Fable 5.1. Lo confirma el usuario.

## 2. Diagnóstico (hechos verificados el 2026-10-22)

| # | Hecho | Evidencia |
|---|---|---|
| H1 | Los 3 duplicados sin seguimiento son idénticos, salvo CRLF, a las versiones de `HEAD` de `CONTEXT`, `DECISIONS` y `HANDOFF`. Se recuperan con `git show HEAD:docs/<canónico>`. | `diff` contra `HEAD`: 0 líneas. |
| H2 | Los canónicos modificados solo añaden la sección 2026-09-25. | `git diff --stat`. |
| H3 | lab08/MongoDB está implementado y versionado (`compose.mongodb.yml` con `mongo:4.4.14`, 8 wrappers, README de perfil y de lab). `DT-043` sigue diciendo "no implementar" y nada la reemplaza. | `git ls-files`, lectura de README y compose. |
| H4 | La versión real de `mongod` docente sigue sin confirmarse. | `DT-043`. |
| H5 | **Corrección:** el tag no está en `.env`. Vive en `conf/image-tags.conf` (`BIGDATA_IMAGE_TAG=v0.4.1`, versionado). `DT-038` dice `v0.4.0`: hubo un avance a `v0.4.1` sin decisión registrada. | `grep`, `git ls-files`. |
| H6 | Ese archivo se consume por tres vías. **PowerShell:** `containers/scripts/common.ps1` (`Get-ProjectEnvMap` y `Get-ComposeEnvArgs`, que devuelve `--env-file`) y `build.ps1`; 21 `.ps1` llaman a esas funciones. **Bash:** `containers/scripts/bash/common.sh` (`load_project_env`) y 19 scripts con `--env-file "$env_file"` (los `down*`, `status*` y `up*`, más `build*.sh` y `pull-images-and-up.sh`). **Privado:** `docs/private/publish-dockerhub.ps1`, línea 30, ruta `conf\image-tags.conf`. Los `compose*.yml` usan `${BIGDATA_IMAGE_TAG}`. | `grep`. |
| H7 | Referencias a versión del proyecto en archivos vivos: `README.md:91` (menciona el archivo), `profiles/ir/README.md:31`, `profiles/nosql-cassandra/README.md:40`, `profiles/sql-hive/README.md:45`. Los README de laboratorio no tienen ninguna. | `grep`. |
| H8 | Las demás menciones de `v0.1.0` a `v0.4.0` están en documentos históricos (`CONTEXT`, `DECISIONS`, `HANDOFF`, `BITACORA_*`, `REGISTRO_CAMBIOS`, `AUDITORIA_*`) y en `docs/private/`. | `grep` con conteos. |
| H9 | `Get-ProjectEnvValue` prioriza la variable de entorno y luego el mapa. Si el mapa sale de `VERSION`, `build.ps1` funciona sin cambios. | `common.ps1:48-58`. |
| H10 | Git Bash disponible, así que `bash -n` es viable localmente. | Herramienta Bash operativa. |

Limitaciones: no se ejecutó ningún build, contenedor ni prueba. No se leyó `.env` ni `docs/private/accesos_servidores.csv`. No se verificó el contenido de los `.ps1` no listados más allá del patrón `@composeEnvArgs`.

## 3. Alcance

**Dentro:**
- Higiene documental y creación de `VERSION`.
- Migración de scripts PowerShell y Bash a `VERSION`, y retiro de `conf/image-tags.conf`.
- Limpieza de menciones de versión en README vivos.
- Reconciliación aditiva de lab08, commits y revalidación.

**Fuera:**
- Reescribir historia: `DECISIONS`, `CONTEXT`, `HANDOFF`, bitácoras y registro de cambios conservan sus menciones (regla 7 de `AGENTS.md`).
- Versiones de componentes de terceros (Java 11.0.26, Hadoop 2.10.0, Spark 3.3.2, Pig 0.18.0-SNAPSHOT, Cassandra 2.0.7, Elasticsearch 6.8.10, `mongo:4.4.14`). No son la versión de este proyecto.
- Refactorizar wrappers, fusionar `build-clean.sh`, actualizar Luna/Tierra en `AGENTS.md`.

## 4. Diseño de la fuente única (cambio mínimo)

- `VERSION` en la raíz, con una sola línea `v0.4.1` y LF final.
- **PowerShell:** en `common.ps1`, `Get-ProjectEnvMap` devuelve `@{ BIGDATA_IMAGE_TAG = <contenido recortado de VERSION> }`. `Get-ComposeEnvArgs` asigna `$env:BIGDATA_IMAGE_TAG` y devuelve `@()`. Los 21 llamadores que usan `@composeEnvArgs` no se tocan.
- **Bash:** en `common.sh`, `load_project_env` lee `VERSION` y exporta `BIGDATA_IMAGE_TAG`. En los 19 scripts se elimina la línea `env_file=...` y el argumento `--env-file "$env_file"`. Compose toma la variable del entorno.
- Se elimina `conf/image-tags.conf` y se reescriben sus mensajes de error y referencias.
- Quien invoque `podman compose` sin los wrappers debe exportar `BIGDATA_IMAGE_TAG` (antes también debía pasar `--env-file`; no hay regresión).

## 5. Decisiones

- **D-A (resuelta 2026-10-22):** eliminar los 3 duplicados.
- **D-B (abierta):** ¿se registra `DT-049` (overlay MongoDB 4.4.14 implementado, `DT-043` matizada)?
- **D-C (abierta):** ¿se autoriza lectura remota de solo lectura de `mongod --version`?
- **D-D (abierta):** ¿se publican las imágenes y qué host Linux se usa (por ejemplo `ServidorQA`)?
- **D-E (abierta, recomendación incluida):** alcance de "quitar toda referencia a versión". Recomendado: solo archivos vivos y de configuración. Los históricos y las versiones de componentes se conservan, y se registra `DT-050` (la versión del proyecto vive solo en `VERSION`; `DT-038` y los tags `v0.1.0`–`v0.4.0` quedan como historia).
- **D-F (abierta):** `docs/private/*` no está versionado y `publish-dockerhub.ps1` fallaría al borrar `conf/image-tags.conf`. ¿Se autoriza ajustarlo (PC-07)?

## 6. Acciones (orden de ejecución)

### PC-01 — Validar el árbol antes de tocarlo
- P0 · READY · Ejecutor.
- Objetivo: confirmar que lo que se commiteará no contiene secretos ni referencias rotas.
- Archivos (solo lectura): `AGENTS.md`, `docs/CONTEXT.md`, `docs/DECISIONS.md`, `docs/HANDOFF.md`.
- Dependencias: ninguna.
- Validación: `git diff` de esos archivos; `grep -nEi "password|passwd|token|secret|BEGIN .*KEY"`; las rutas citadas en `AGENTS.md` existen.
- Aceptación: cero coincidencias de secretos y rutas existentes. Si algo falla, detener y pasar a Planificador.

### PC-02 — Retirar los 3 duplicados
- P0 · READY · Ejecutor. Autorizado por el usuario (D-A).
- Archivos: eliminar `docs/CONTEXTO_PROYECTO.md`, `docs/DECISIONES_TECNICAS.md`, `docs/PENDIENTES.md`.
- Dependencias: PC-01.
- Precondición: repetir el `diff` normalizando CRLF contra `git show HEAD:docs/CONTEXT.md` (y los otros dos), con 0 diferencias. Si difiere, detener.
- Recuperación: `git show HEAD:docs/<canónico>`.
- Validación: `git status --short` ya no los lista; los 3 canónicos siguen presentes.
- Aceptación: no quedan los 3 archivos y los canónicos no cambiaron. No se tocan los documentos históricos que los citan.

### PC-03 — Crear `VERSION`
- P0 · READY · Ejecutor.
- Archivos: `VERSION` (nuevo, raíz).
- Cambio: una sola línea `v0.4.1` con LF final, sin BOM.
- Dependencias: ninguna.
- Validación: `cat -A VERSION` muestra `v0.4.1$`; `git check-ignore VERSION` no devuelve nada.
- Aceptación: contenido exacto y archivo no ignorado por Git.

### PC-04 — Migrar PowerShell a `VERSION`
- P0 · READY · Ejecutor (esfuerzo medio).
- Archivos: `containers/scripts/common.ps1` (único). `build.ps1` y los 21 llamadores no cambian (H9).
- Cambio: según la sección 4. Actualizar los mensajes de error para citar `VERSION`. Preservar los errores de archivo ausente o vacío.
- Dependencias: PC-03.
- Validación: parseo con `[System.Management.Automation.Language.Parser]::ParseFile`; `. .\containers\scripts\common.ps1; Get-RequiredProjectEnvValue -Root . -Name BIGDATA_IMAGE_TAG` devuelve `v0.4.1`; `Get-ComposeEnvArgs` devuelve vacío y fija `$env:BIGDATA_IMAGE_TAG`. Opcional, si Podman está disponible: `podman compose -f compose.yml config` muestra `:v0.4.1` en los `image:`.
- Aceptación: las tres comprobaciones pasan. Declarar que no se probaron `up`/`build`.
- Riesgo: un llamador que no use `@composeEnvArgs` (verificar con `grep` antes de editar).

### PC-05 — Migrar Bash a `VERSION`
- P0 · READY · Ejecutor (esfuerzo medio).
- Archivos: `containers/scripts/bash/common.sh`; eliminan `env_file` y `--env-file`: `down*.sh`, `status*.sh`, `up*.sh`, `pull-images-and-up.sh`; mensajes en `build.sh` y `build-clean.sh`.
- Cambio: según la sección 4. Reemplazar los mensajes que citan `conf/image-tags.conf` por `VERSION`.
- Dependencias: PC-03.
- Validación: `bash -n` en todos los `.sh` de `containers/scripts/bash/`; `grep -rn "env_file\|image-tags" containers/scripts/bash` devuelve 0; `source common.sh; load_project_env <raíz>; echo $BIGDATA_IMAGE_TAG` imprime `v0.4.1`.
- Aceptación: las tres comprobaciones pasan. Es paridad estática con PC-04, no ejecución en Linux (eso es PC-14).

### PC-06 — Retirar `conf/image-tags.conf` y limpiar README vivos
- P1 · READY · Ejecutor (esfuerzo bajo).
- Archivos: eliminar `conf/image-tags.conf` (versionado, reversible con Git); editar `README.md:91` (citar `VERSION`) y reformular sin versión `profiles/ir/README.md:31`, `profiles/nosql-cassandra/README.md:40`, `profiles/sql-hive/README.md:45`.
- Dependencias: PC-04, PC-05.
- Validación: `grep -rn "image-tags" . --exclude-dir=.git --exclude-dir=private` no devuelve nada fuera de documentos históricos; `grep -n "v0\.[0-9]" README.md profiles/*/README.md` devuelve 0.
- Aceptación: la única fuente de versión del proyecto es `VERSION` en archivos vivos. El significado de cada frase de perfil se conserva sin el número.

### PC-07 — Ajustar scripts privados no versionados
- P1 · REQUIRES_CONFIRMATION (D-F) · Ejecutor.
- Archivos: `docs/private/publish-dockerhub.ps1` (línea 30 y comentario línea 8), más `docs/private/pull-images-and-up.ps1` y `docs/FLUJO_PULL_DOCKER_HUB.md` si citan el archivo o el tag.
- Cambio: leer `VERSION` en lugar de `conf\image-tags.conf`. No imprimir ni copiar credenciales.
- Dependencias: PC-06.
- Validación: parseo `PowerShell`; `grep` de `image-tags` en `docs/private`.
- Aceptación: sin referencias a `conf/image-tags.conf`. Archivos fuera de Git: se hace copia previa (`.bak` local) por no tener recuperación.

### PC-08 — Reconciliar lab08 y registrar `VERSION` en los canónicos
- P1 · REQUIRES_CONFIRMATION (D-B, D-E) · Ejecutor, con el texto aprobado de PC-11.
- Archivos: `docs/DECISIONS.md`, `docs/HANDOFF.md`, `docs/CONTEXT.md`.
- Cambio: solo añadir al final. `DT-049` (MongoDB 4.4.14 implementado; `DT-043` matizada) y `DT-050` (`VERSION` única, tag actual `v0.4.1`, `DT-038` queda histórica). Nota de estado en HANDOFF y CONTEXT.
- Dependencias: PC-02, PC-11, PC-06.
- Validación: `git diff` muestra solo líneas añadidas; `DT-001` a `DT-048` intactas.
- Aceptación: diff aditivo que coincide con el texto aprobado.
- Riesgo: regla 7 de `AGENTS.md`; este plan cuenta con la solicitud expresa solo si se confirman D-B y D-E.

### PC-09 — Validación estática previa al commit
- P1 · READY · Ejecutor (esfuerzo bajo).
- Dependencias: PC-04, PC-05, PC-06.
- Validación: `bash -n` en todos los `.sh`; parseo de todos los `.ps1` de `containers/scripts/`; `git diff --stat`; `grep -rnE "v[0-9]+\.[0-9]+\.[0-9]+" README.md profiles conf containers compose*.yml` devuelve solo versiones de componentes; paridad `.ps1` ↔ `.sh` por nombre.
- Aceptación: sin fallos de sintaxis y sin tag de proyecto fuera de `VERSION`. Cobertura: sintaxis y referencias; no prueba ejecución.

### PC-10 — Commits
- P1 · REQUIRES_CONFIRMATION · Ejecutor.
- Cambio: tres commits con staging explícito archivo por archivo (no `git add -A`): (a) `AGENTS.md`; (b) `VERSION` y la migración (scripts, retiro de `conf/image-tags.conf`, README); (c) documentación de continuidad y plan (`docs/*`, `logs/planificacion.jsonl`). Mensajes en español con la coautoría indicada por la sesión. Sin push.
- Dependencias: PC-01, PC-02, PC-09 y PC-08 (si se aprobó).
- Validación: `git show --stat` de cada commit y `git status` limpio.
- Aceptación: árbol limpio y ningún archivo fuera de lo planificado.

### PC-11 — Auditar la contradicción de lab08
- P1 · READY · Planificador.
- Archivos (solo lectura): `data/shared/lab08/{README.md,logs,results,notes}`, `compose.mongodb.yml`, wrappers `*mongodb*`, `docs/DECISIONS.md` (`DT-043`), `docs/HANDOFF.md`.
- Cambio: entregar el texto propuesto de `DT-049`/`DT-050` y de las notas, sin escribirlo.
- Dependencias: ninguna.
- Validación: cada evidencia se cita con archivo y fecha; lo que solo aparece en el README se marca como no verificado.
- Aceptación: el borrador distingue evidencia de declaración y no afirma ejecución nueva.

### PC-12 — Revalidar `mongod` docente en solo lectura
- P1 · REQUIRES_CONFIRMATION (D-C) · Planificador.
- Cambio: solo `mongod --version`, `ps` filtrado por mongod y `ss -ltn` filtrado por 27017. Las credenciales de `docs/private/accesos_servidores.csv` se usan solo para conectar y no se imprimen. Salida literal en una nota nueva bajo `data/shared/lab08/notes/`.
- Dependencias: PC-11.
- Aceptación: versión confirmada o "no determinable". Si difiere de 4.4.14, abrir una acción nueva; no editar el compose aquí.

### PC-13 — Revalidación local en Windows/Podman
- P1 · REQUIRES_CONFIRMATION (escribe estado) · Ejecutor; Planificador si algo falla.
- Cambio: ninguno en código. Orden: `status.ps1` → `smoke-test.ps1` → `build.ps1 -NoCache` → `test-operational.ps1`. **No ejecutar `reset-data.ps1`.**
- Dependencias: PC-04, PC-06.
- Aceptación: cada comando termina con éxito, las imágenes llevan el tag `v0.4.1` y queda evidencia fechada en `evidencia/`. Cobertura: solo el `core`.

### PC-14 — Validación runtime de wrappers Bash en Linux real
- P1 · BLOCKED (D-D: sin host Linux autorizado) · Ejecutor; Planificador ante fallos.
- Dependencias: PC-05, PC-09, PC-13 y un host Linux con Podman autorizado.
- Validación: `bash -n`, `status.sh`, `up.sh`, `test-operational.sh` y los overlays que se decidan probar.
- Aceptación: salida real registrada, con lista de lo no probado.
- Riesgo: diferencias Docker/Podman y límites de `podman-compose` (sin `--profile` en 1.0.6).

### PC-15 — Decidir publicación de `v0.4.1`
- P2 · REQUIRES_CONFIRMATION (D-D) · Superior (decisión); Ejecutor para `pull`/`tag`/`push` si se aprueba.
- Archivos: `docs/DECISIONS.md` (entrada aditiva).
- Dependencias: PC-13, PC-14.
- Aceptación: decisión registrada. Publicar es una acción externa y requiere autorización explícita.

## 7. Secuencia

```
Independientes (READY): PC-01, PC-03, PC-11
PC-01 → PC-02
PC-03 → PC-04, PC-05 → PC-06 → PC-07, PC-09
PC-11 → PC-08, PC-12
PC-02, PC-06, PC-11 → PC-08
PC-01, PC-02, PC-09 (+PC-08) → PC-10
PC-04, PC-06 → PC-13 → PC-14 → PC-15
```

Ruta mínima hacia `VERSION` única y árbol limpio: PC-01 → PC-02 → PC-03 → PC-04/05 → PC-06 → PC-09 → PC-10.

## 8. Trazabilidad

| Requerimiento | Decisión/hecho | Acciones | Validación |
|---|---|---|---|
| Eliminar duplicados | H1, D-A | PC-01, PC-02 | `diff` vs `HEAD`, `git status` |
| `VERSION` única = v0.4.1 | H5–H9, D-E, D-F | PC-03 a PC-07, PC-09 | parseo, `grep`, `bash -n`, `config` |
| Commit | `DT-048` | PC-10 | `git show --stat`, `git status` |
| lab08/MongoDB | H3, H4, D-B, D-C | PC-08, PC-11, PC-12 | `git diff` aditivo, nota local |
| Bash y cierre de versión | `DT-039`, D-D | PC-13, PC-14, PC-15 | `evidencia/`, salida en Linux |

## 9. Asignación de roles

- **Ejecutor (económico):** PC-01 a PC-07, PC-09, PC-10, y la ejecución de PC-13 y PC-14.
- **Planificador:** PC-11, PC-12, y el diagnóstico de fallos en PC-13 y PC-14.
- **Superior:** PC-15 y cualquier decisión nueva de arquitectura (por ejemplo, si `D-E` cambia el diseño de la fuente única).
- Se escala del Ejecutor al Planificador o al Superior solo ante una condición no prevista que afecte arquitectura, datos, seguridad, dependencias o persistencia (regla de `AGENTS.md`).
