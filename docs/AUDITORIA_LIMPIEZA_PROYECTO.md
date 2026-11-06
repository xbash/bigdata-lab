# Auditoría de limpieza del proyecto

Fecha de corte: `2026-09-25`  
Proyecto: `C:\rutinas-local\gen-container\bigdata-lab`  
Tipo de revisión: inspección estática, sin ejecutar cambios operativos ni modificar, mover o eliminar archivos.

## 1. Alcance y criterio

La auditoría buscó artefactos residuales de iteraciones de desarrollo, especialmente análisis, planes, borradores, reportes, temporales, documentación obsoleta, salidas generadas y copias empaquetadas.

Se revisaron el árbol de archivos, el estado de Git, `.gitignore`, `README.md`, documentación de continuidad, referencias textuales y la distribución de fuentes, scripts, datos, `work/`, `logs/`, `results/`, `evidencia/` y `docs/private/`.

La clasificación significa:

- `MANTENER`: existe uso actual, dependencia operacional o valor histórico/técnico claro.
- `REVISAR`: podría conservarse, archivarse o consolidarse, pero requiere decisión humana o verificación adicional.
- `ELIMINAR`: no se encontró uso actual y el indicio de artefacto temporal o de una iteración terminada es fuerte; la eliminación queda solo propuesta, no ejecutada.

La evidencia de “no referenciado” significa que no se encontró una referencia textual en los archivos consultados; no demuestra por sí sola que ningún usuario lo utilice manualmente.

## 2. Hallazgos generales

- El repositorio conserva una separación intencional entre infraestructura reusable, materiales de laboratorios, código fuente de prácticas, evidencias y documentación privada.
- `.artifacts/pig-0.18.0-SNAPSHOT-course.tgz` y su hash son insumos explícitos del build; no son residuos.
- `data/shared/lab0X/work/` contiene material ejecutable de los laboratorios: fuentes, `build.xml`, bibliotecas y clases/jars compilados. No debe limpiarse como si fuera una caché sin validar antes cada flujo.
- `data/shared/lab0X/logs/` y `data/shared/lab0X/results/` son destinos operativos documentados, pero contienen salidas generadas e ignoradas por Git. Conviene aplicar una política de retención, no una eliminación masiva automática.
- `data/shared/lab01.zip` a `data/shared/lab08.zip` son archivos no rastreados por Git, creados el `2026-09-16`, que empaquetan laboratorios completos. No se encontró una referencia operativa a ellos; son los candidatos de mayor tamaño y mayor probabilidad de duplicación.
- `docs/private/` está excluido por `.gitignore`, pero no todo su contenido es temporal: incluye scripts operativos, cierres, decisiones y material de referencia remoto.
- `docs/private/accesos_servidores.csv` contiene información de acceso sensible. El informe no reproduce sus valores. Debe tratarse como un riesgo de seguridad y no como un simple residuo documental.

## 3. Matriz de candidatos

| Ruta | Tipo | Uso actual | Evidencia | Propósito original | Clasificación | Riesgo | Acción propuesta |
|---|---|---|---|---|---|---|---|
| `.artifacts/` y `pig-0.18.0-SNAPSHOT-course.tgz.sha256` | Artefacto de build + hash | Usado por los builds PowerShell/Bash y por los `Containerfile` base | `README.md`; `containers/scripts/build.ps1`; `containers/scripts/build.sh`; `containers/base/Containerfile`; `docs/DECISIONES_TECNICAS.md` | Fijar el insumo exacto de Pig para reproducibilidad | `MANTENER` | Alto si se elimina: el build puede dejar de ser reproducible | Mantener. Verificar periódicamente que el hash corresponda al archivo y documentar almacenamiento externo solo como alternativa explícita |
| `logs/` raíz, incluidos `hadoop/`, `spark/`, `yarn/` y subdirectorios vacíos | Directorios de runtime heredados | No contienen archivos actualmente; el stack base dejó de montar esta ruta | `Get-ChildItem`; `docs/DECISIONES_TECNICAS.md` DT-010; `docs/CONTEXTO_PROYECTO.md` | Antiguo destino de logs/bind mount del runtime | `REVISAR` | Bajo en datos, medio por referencias/documentación que podrían inducir a usarlo | Confirmar si se conserva como estructura visual o se elimina junto con referencias obsoletas; no tocar volúmenes Podman |
| `evidencia/` y sus seis `smoke-test-*.log` | Evidencia de pruebas | Referenciada por README, scripts y bitácoras; contiene resultados de smoke tests | `README.md`; `containers/scripts/smoke-test.ps1`; `docs/BITACORA_CODEX.md`; `.gitignore` | Registrar evidencia local de validaciones | `MANTENER` | Bajo si se conserva; riesgo de confundir evidencia histórica con estado actual | Mantener con fecha, alcance y estado de cada evidencia; definir retención para duplicados |
| `docs/private/accesos_servidores.csv` | Configuración sensible | No se encontró referencia textual en scripts/documentación consultados; contiene campos de credenciales y rutas privadas | Inspección del encabezado y contenido del CSV; `.gitignore` excluye `docs/private/` | Centralizar accesos para operaciones remotas | `REVISAR` | Crítico: exposición o reutilización de credenciales, aunque el archivo esté fuera de Git | Verificar si sigue siendo necesario, retirar secretos del checkout, rotar credenciales si fueron reales/activas y reemplazar por un mecanismo seguro. No eliminar sin confirmar recuperación de accesos |
| `docs/private/exports/` y sus dos árboles fechados, incluido el sufijo `-v2` | Exportaciones remotas | No se encontraron consumidores automáticos; conservan 23 archivos y dos versiones de exportación | Inventario de archivos; `docs/private/INVENTARIO_REMOTO_Y_MATRIZ_LABS_01_05.md`; memoria documental del inventario remoto | Preservar exportaciones de Cassandra/MongoDB del levantamiento docente | `REVISAR` | Medio: duplicación, datos sensibles o pérdida de trazabilidad si se borra la versión equivocada | Comparar manifiestos y hashes entre ambas versiones, identificar la versión canónica, conservar un archivo histórico fuera del checkout si corresponde y eliminar solo duplicados confirmados |
| `docs/private/analisis-arquitectura-base.md` | Análisis de diseño | Sin referencia operativa actual encontrada; el documento declara diseño `v0.1.0` aprobado | Encabezado del archivo; decisiones posteriores en `docs/DECISIONES_TECNICAS.md` y `docs/CONTEXTO_PROYECTO.md` | Diseñar el core inicial de cuatro contenedores | `REVISAR` | Medio: puede contradecir la arquitectura posterior `core + overlays` | Conservar como histórico si se necesita trazabilidad; si no, extraer decisiones vigentes y archivar fuera del árbol activo |
| `docs/private/PLAN_IMPLEMENTACION_LABS_04_06.md` | Plan de implementación | No se encontraron consumidores; los laboratorios 04–06 ya tienen cierres/evidencia posteriores | Referencia histórica en `docs/REGISTRO_CAMBIOS.md`; archivos de cierre y bitácoras | Guiar una iteración inicial de implementación | `REVISAR` | Medio: plan vencido puede confundirse con backlog vigente | Marcarlo explícitamente como histórico o consolidar solo pendientes aún vigentes en `docs/PENDIENTES.md` |
| `docs/private/pendientes_lista.md` | Resumen de pendientes | No se encontró uso automático; varios estados son anteriores a cierres posteriores | Contenido del archivo; comparación con `docs/PENDIENTES.md`, `docs/CONTEXTO_PROYECTO.md` y cierres | Consolidar backlog de una sesión anterior | `REVISAR` | Medio: duplicidad y estados stale, especialmente respecto de Lab06 | Comparar con `docs/PENDIENTES.md`, conservar una única fuente de verdad y archivar/eliminar la copia cuando no tenga información exclusiva |
| `docs/private/INVENTARIO_REMOTO_Y_MATRIZ_LABS_01_05.md` | Inventario histórico | Sin consumo automático; aporta contexto del ambiente docente y exportaciones | Contenido del archivo; `docs/REGISTRO_CAMBIOS.md`; `docs/private/exports/` | Documentar inspección remota de solo lectura | `MANTENER` | Medio: observaciones remotas pueden quedar obsoletas | Mantener como histórico fechado, etiquetar como no actual y evitar usarlo como prueba del estado remoto presente |
| `docs/private/CIERRE_LABS_01_03.md`, `CIERRE_LAB04.md`, `CIERRE_LAB05.md` | Cierres documentales | No son consumidos por scripts, pero registran cierres y alcance validado | Encabezados con estados `CERRADO`; coincidencia con bitácoras y resultados | Dejar una constancia breve de cierre de laboratorios | `MANTENER` | Bajo; riesgo principal de duplicación documental | Mantener si se requiere trazabilidad académica; enlazar desde un índice documental o consolidar solo si el equipo decide una fuente única |
| `docs/private/COMANDOS_OPERATIVOS_LAB01.md` | Guía operativa | Referencia manual para la interfaz actual `-Mode InMemory|External|Both` | Contenido del archivo; scripts de `data/shared/lab01/scripts/`; decisiones técnicas | Facilitar la ejecución reproducible de Lab01 | `MANTENER` | Bajo; puede quedar desalineado si cambia la interfaz | Mantener y actualizar junto con los wrappers de Lab01 |
| `docs/private/ARTEFACTO_PIG_0_18_0_SNAPSHOT.md` | Nota técnica | Documenta el artefacto requerido por el build | `.artifacts/`; `README.md`; `docs/DECISIONES_TECNICAS.md` | Formalizar la procedencia y hash del artefacto Pig | `MANTENER` | Bajo | Mantener como contrato de reproducibilidad |
| `docs/private/FLUJO_PULL_DOCKER_HUB.md` | Procedimiento operativo | Referenciado por la documentación de continuidad para pull/tag/up | `docs/CONTEXTO_PROYECTO.md`; `docs/DECISIONES_TECNICAS.md`; script de pull | Documentar rehidratación desde imágenes publicadas | `MANTENER` | Medio si sus tags quedan obsoletos | Mantener, pero separar claramente evidencia histórica de tags actuales y revalidar antes de publicar nuevas instrucciones |
| `docs/private/pull-images-and-up.ps1` y `sync-servidorqa.ps1` | Scripts operativos privados | Referenciados y descritos como utilitarios vigentes para pull/sincronización | `docs/DECISIONES_TECNICAS.md`; `docs/CONTEXTO_PROYECTO.md`; contenido de los scripts | Operar pull de imágenes y sincronización hacia ServidorQA | `MANTENER` | Alto si se ejecutan con parámetros incorrectos; realizan acciones externas | Mantener fuera del árbol público, revisar parámetros/credenciales antes de uso y conservar separación respecto de scripts de publicación |
| `docs/private/publish-dockerhub.ps1`, `publish-github.ps1` y `push_images.ps1` | Scripts de publicación | No se encontraron referencias activas; tienen efectos externos potenciales | Inventario y contenido de scripts; ausencia de referencias textuales | Automatizar publicación de imágenes o del branch | `REVISAR` | Alto: publicación accidental, tags incorrectos o exposición de cambios | Confirmar si siguen autorizados; añadir guardas y documentación de uso o archivar fuera del checkout. No ejecutar durante esta auditoría |
| `docs/private/SET_PRUEBAS_SCRIPTS_OPERACIONALES.md` | Plan/checklist de pruebas | No se encontró consumidor automático; describe un set de pruebas operacionales | Contenido del archivo; scripts bajo `containers/scripts/` | Guiar validación de scripts del runtime | `REVISAR` | Bajo/medio: puede quedar desactualizado frente a scripts actuales | Comparar con el árbol real y convertirlo en checklist mantenido o archivarlo como evidencia de una iteración |
| `docs/private/dame los pasos a paso para construir los contenedores.docx` | Documento de solicitud/borrador | No se encontró referencia; el nombre describe una petición puntual y el archivo no es legible como Markdown | Nombre, tipo DOCX, ausencia de referencias | Producir una guía puntual para construir contenedores | `ELIMINAR` | Medio: podría contener instrucciones únicas no migradas; bajo valor como artefacto operativo sin referencia | Antes de eliminar, abrir/revisar su contenido y confirmar que la información ya está en `README.md`/scripts; después archivar o eliminar según esa confirmación |
| `data/shared/lab01/work/` | Fuentes, build y binarios del laboratorio | Contiene `src/`, `build.xml`, librerías y `.class`; la documentación lo identifica como proyecto ejecutable | `git ls-files`; `data/shared/lab01/scripts/`; `docs/CONTEXTO_PROYECTO.md`; `docs/DECISIONES_TECNICAS.md` | Material autocontenido y compilable de Lab01 | `MANTENER` | Alto si se elimina: se pierde código o reproducibilidad; posible costo de espacio por binarios | Mantener. Evaluar por separado si los binarios compilados deben regenerarse, pero no eliminarlos sin prueba de compilación y ejecución |
| `data/shared/lab02/work/` a `data/shared/lab06/work/` | Fuentes, dependencias y binarios de laboratorios | Referenciados por scripts, cierres y documentación; contienen código fuente y artefactos usados en los jobs | `git ls-files`; README de cada laboratorio; `docs/CONTEXTO_PROYECTO.md`; `docs/REGISTRO_CAMBIOS.md` | Material ejecutable de Hadoop, Pig, Spark, Elasticsearch/Giraph | `MANTENER` | Alto: eliminación rompe prácticas o compilación; hay dependencias embebidas que no deben confundirse con caché | Mantener. Si se necesita ahorrar espacio, diseñar una política separada para reconstrucción de `bin/`, `dist/` y `lib/`, con validación funcional por laboratorio |
| `data/shared/lab05/notes/remote-configs/20260729/` | Notas/configuración histórica remota | Referenciada por documentos de contexto y cambios; no es parte del runtime automático | `docs/CONTEXTO_PROYECTO.md`; `docs/REGISTRO_CAMBIOS.md`; `.gitignore` | Conservar configuraciones observadas para reproducir Lab05 | `MANTENER` | Medio: datos remotos pueden estar obsoletos o ser sensibles | Mantener con fecha y alcance; revisar que no incluya secretos antes de compartir o versionar |
| `data/shared/lab01/logs/` y `data/shared/lab01/results/` | Salidas generadas de múltiples corridas | Los scripts escriben allí y la documentación los trata como destinos canónicos; hay 280 logs y 6 resultados | `.gitignore`; scripts de Lab01; `docs/CONTEXTO_PROYECTO.md`; `docs/PENDIENTES.md` | Retener trazas, resúmenes y resultados de experimentos | `REVISAR` | Medio: acumulación, confusión entre corridas fallidas y evidencia final; 46,8 MB de resultados | Seleccionar corridas canónicas, conservar `runs_summary.csv` y evidencia final, documentar una retención y eliminar solo logs repetidos tras confirmar que no respaldan una decisión |
| `data/shared/lab02/logs/`–`data/shared/lab07/logs/` y `results/` | Salidas generadas de jobs y pruebas | Son destinos operativos documentados; contienen logs/resultados ignorados por Git, con volúmenes relevantes en Lab05/Lab06 | README de cada laboratorio; `.gitignore`; `docs/CONTEXTO_PROYECTO.md`; `docs/REGISTRO_CAMBIOS.md` | Evidencia local de ejecuciones, previews y entregables | `REVISAR` | Medio: pérdida de evidencia, datos duplicados o retención indefinida; Lab05/Lab06 concentran decenas de MB | Mantener los resultados finales y logs asociados a cierres; separar fallos diagnósticos de evidencia académica y aplicar retención por laboratorio |
| `data/shared/lab01.zip` … `data/shared/lab08.zip` | Paquetes ZIP completos no rastreados | No se encontró referencia en scripts/documentación; cada ZIP replica un árbol `lab0X/` y fue creado el `2026-09-16` | `git status`; `git ls-files --others`; `tar -tf`; tamaños entre aproximadamente 11 MB y 495 MB | Empaquetar laboratorios completos para traslado o respaldo | `REVISAR` | Alto en almacenamiento y trazabilidad; pueden incluir logs, resultados y binarios obsoletos o datos sensibles | Comparar cada ZIP contra el directorio actual mediante manifiesto/hash, confirmar si son respaldos autorizados, mover a almacenamiento de releases/backup si corresponde y eliminar duplicados solo después de esa decisión |

## 4. Resumen por categoría

El conteo se realiza sobre las 23 filas/unidades de auditoría de la matriz; algunas filas agrupan conjuntos homogéneos de archivos o directorios y lo indican explícitamente.

| Categoría | Cantidad de unidades | Interpretación |
|---|---:|---|
| `MANTENER` | 11 | Insumos de build, evidencia, material ejecutable, documentación histórica útil o scripts operativos todavía relevantes |
| `REVISAR` | 11 | Candidatos a consolidación, archivado, retención selectiva, saneamiento de datos sensibles o verificación de duplicados |
| `ELIMINAR` | 1 | Documento DOCX aparentemente puntual, sujeto a confirmar que no contenga información única |

## 5. Principales residuos detectados

1. Ocho ZIP completos no rastreados bajo `data/shared/`, que duplican laboratorios y pueden contener salidas generadas, binarios y documentación ya presente en el árbol.
2. Documentación privada de iteraciones previas: análisis de arquitectura `v0.1.0`, plan de Labs 04–06 y lista de pendientes duplicada frente a la documentación vigente.
3. El DOCX `dame los pasos a paso para construir los contenedores.docx`, cuyo nombre y ausencia de referencias son compatibles con un artefacto de solicitud o borrador de uso único.
4. Acumulación de logs y resultados locales, especialmente en Lab01 y en los flujos de Lab05/Lab06. Son salidas operativas, no residuos eliminables sin retención selectiva.
5. Directorios vacíos bajo `logs/` raíz, probablemente remanentes del diseño anterior de bind mounts.
6. Material privado de publicación y sincronización sin referencias activas. Su riesgo no es solo obsolescencia: algunos scripts pueden producir efectos externos.
7. Un archivo privado de accesos con información sensible. Requiere tratamiento prioritario de seguridad, revisión de vigencia y posible rotación de credenciales.

## 6. Casos ambiguos que requieren decisión humana

- ¿Los ocho ZIP son respaldos oficiales, paquetes de entrega o duplicados prescindibles? La decisión debe considerar fecha, procedencia, integridad y necesidad de recuperación.
- ¿Debe mantenerse `docs/private/analisis-arquitectura-base.md` como registro histórico o consolidarse en las decisiones técnicas actuales?
- ¿Cuál es la única fuente de verdad para pendientes: `docs/PENDIENTES.md` o `docs/private/pendientes_lista.md`?
- ¿Las exportaciones remotas `2026-08-05` y `2026-08-05-...-v2` son versiones distintas necesarias o una duplicación?
- ¿El DOCX contiene instrucciones únicas que deban migrarse a `README.md` antes de eliminarlo?
- ¿Qué logs y resultados constituyen evidencia académica final y cuáles son repeticiones/fallos de diagnóstico que pueden retenerse fuera del checkout?
- ¿Los binarios y bibliotecas bajo `data/shared/*/work/` deben conservarse para ejecución inmediata o puede definirse una reconstrucción reproducible desde fuentes y dependencias?
- ¿El CSV de accesos debe seguir existiendo localmente? Si contiene credenciales activas, la decisión correcta debe incluir rotación y reemplazo por almacenamiento seguro, no solo borrado del archivo.
- ¿Los scripts privados de publicación (`publish-*`, `push_images.ps1`) siguen autorizados y alineados con el estado actual del proyecto?

## 7. Plan de acción propuesto, sin ejecutar

### Fase 1: proteger y congelar evidencia

1. No ejecutar scripts de publicación o sincronización durante la limpieza.
2. Verificar y, si corresponde, rotar credenciales asociadas a `docs/private/accesos_servidores.csv`.
3. Crear un inventario con rutas, tamaños, fechas y hashes de los ocho ZIP y de los dos árboles de `docs/private/exports/`.
4. Respaldar fuera del checkout la evidencia que se decida conservar antes de cualquier eliminación.

### Fase 2: decidir fuentes canónicas

1. Elegir entre `docs/PENDIENTES.md` y `docs/private/pendientes_lista.md`.
2. Marcar como histórico el análisis `v0.1.0` y el plan de Labs 04–06, o migrar sus decisiones aún vigentes.
3. Definir la política de retención de `logs/` y `results/` por laboratorio.
4. Confirmar si `logs/` raíz debe desaparecer o mantenerse como estructura vacía documentada.

### Fase 3: limpieza autorizada

1. Revisar el contenido del DOCX y eliminarlo o archivarlo solo después de confirmar que no aporta instrucciones únicas.
2. Eliminar únicamente ZIP duplicados confirmados mediante comparación de manifiestos/hashes y decisión explícita sobre su respaldo.
3. Depurar logs/resultados repetidos preservando cierres, resúmenes, resultados canónicos y evidencia necesaria para reproducibilidad.
4. Archivar o retirar documentación obsoleta y scripts de publicación no autorizados, manteniendo un registro de la decisión.

### Fase 4: validación posterior

1. Ejecutar validación estática de referencias rotas y sintaxis Markdown/PowerShell afectada.
2. Ejecutar una prueba de humo proporcional en el ambiente local, sin borrar volúmenes persistentes ni contenedores.
3. Verificar `git status`, `.gitignore`, integridad del artefacto Pig y disponibilidad de los laboratorios que se mantengan.
4. Actualizar la documentación de continuidad con los elementos removidos, respaldados y conservados.

## 8. Limitaciones de esta auditoría

- No se ejecutaron Podman, jobs de laboratorio, scripts de publicación, sincronización remota ni pruebas funcionales.
- No se evaluó el contenido visual del DOCX; su clasificación es provisional hasta abrirlo y revisarlo.
- No se verificó el estado actual de servidores remotos ni la vigencia de credenciales.
- No se puede afirmar que la ausencia de referencias textuales implique ausencia de uso manual.
- Ningún archivo, directorio, volumen, contenedor, imagen o dato fue modificado, movido o eliminado.
