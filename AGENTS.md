# AGENTS.md — bigdata-lab

Estas instrucciones se aplican a todo el repositorio y definen reglas persistentes para agentes que lo inspeccionen, modifiquen o validen.

## Propósito y límites

`bigdata-lab` mantiene un entorno local reproducible para laboratorios de Big Data basado en contenedores. No reemplaza el ambiente docente ni permite inferir equivalencia funcional, de versiones, recursos o resultados con este.

El repositorio separa infraestructura reutilizable, perfiles tecnológicos y materiales específicos de cada laboratorio. Preserva esa separación al realizar cambios.

No presentes resultados históricos, logs existentes o artefactos versionados como evidencia de una ejecución actual. Una ejecución nueva requiere validación en el entorno donde se realizó.

## Rutas canónicas

- `README.md`: propósito, requisitos, uso general y flujos de operación.
- `compose*.yml`, `containers/` y `conf/`: infraestructura, imágenes, configuración y wrappers operacionales.
- `VERSION`: única fuente de la versión del proyecto y del tag de las imágenes (`BIGDATA_IMAGE_TAG`).
- `profiles/<perfil>/README.md`: uso y límites de cada overlay.
- `data/shared/lab0X/`: material, scripts, código, datasets y documentación propios de cada laboratorio.
- `data/shared/lab0X/README.md`: flujo, insumos y evidencia de ese laboratorio.
- `docs/DECISIONS.md`: decisiones técnicas históricas y justificadas.
- `docs/CONTEXT.md`, `docs/HANDOFF.md`, bitácoras y registro de cambios: estado, continuidad, pendientes, evidencia histórica y trazabilidad.

No copies en este archivo instrucciones de uso, decisiones, planes, resultados, pendientes ni bitácoras. Referencia el documento canónico correspondiente.

## Reglas de modificación

1. Antes de cambiar infraestructura, configuración, wrappers o código, lee el `README.md` aplicable, los archivos afectados y sus referencias directas.
2. Mantén la arquitectura `core` más overlays; no incorpores componentes de un perfil al flujo base sin una necesidad demostrada y una decisión explícita.
3. Realiza cambios mínimos, localizados y reversibles. No refactorices ni actualices dependencias, imágenes o versiones solo por oportunidad.
4. Conserva la configuración externa en `conf/`, y evita codificar rutas locales, credenciales, tokens, secretos o datos personales.
5. Usa los wrappers existentes como interfaz operacional preferida. Si cambias el comportamiento de un wrapper que tiene equivalente PowerShell o Bash, evalúa y actualiza el equivalente cuando corresponda para preservar la paridad declarada.
6. Mantén los materiales y resultados de cada laboratorio dentro de su árbol `data/shared/lab0X/`; no mezcles resultados generados con infraestructura reutilizable.
7. No sustituyas documentación específica de un laboratorio por reglas globales ni modifiques documentos históricos para registrar trabajo nuevo salvo que la tarea lo solicite expresamente.

## Seguridad y operaciones destructivas

- No expongas ni agregues secretos, claves, certificados, archivos `.env`, credenciales de servicios o datos sensibles en código, documentación, logs o salidas.
- Trata como potencialmente destructivas la eliminación de archivos, imágenes, contenedores, volúmenes, datos HDFS, resultados, cambios masivos de configuración, migraciones y cambios de dependencias.
- `containers/scripts/reset-data.ps1` elimina volúmenes del runtime local: requiere autorización explícita y una explicación previa de alcance e impacto.
- Antes de una operación destructiva o de alto impacto, identifica referencias, persistencia afectada, recuperación disponible y validación posterior.
- No asumas que Docker y Podman tienen comportamiento idéntico. Verifica el flujo con Podman cuando el cambio afecte contenedores, Compose, volúmenes, redes o recursos.
- No realices operaciones sobre ambientes remotos o docentes sin autorización explícita. Las observaciones remotas deben ser de solo lectura, salvo instrucción contraria.

## Calidad y validación

- Distingue hechos verificados, supuestos, riesgos, limitaciones y recomendaciones. No inventes compatibilidad, versiones, métricas, resultados de rendimiento ni evidencia de ejecución.
- Valida de forma proporcional al riesgo y declara claramente qué no fue probado.
- Para cambios de archivos estáticos, realiza como mínimo revisión de sintaxis, referencias y consistencia con la documentación directa.
- Para cambios de infraestructura, usa primero verificaciones de bajo impacto y los wrappers del repositorio. Los comandos de referencia son:

  ```powershell
  powershell -ExecutionPolicy Bypass -File .\containers\scripts\status.ps1
  powershell -ExecutionPolicy Bypass -File .\containers\scripts\smoke-test.ps1
  ```

  Ejecuta construcción, levantamiento, detención o pruebas que escriban estado solo cuando el alcance de la tarea lo justifique y el usuario lo haya autorizado.
- Una prueba de humo o una validación estática no prueba todos los overlays ni todos los laboratorios. Declara su cobertura real.

## Selección eficiente de modelos y herramientas

Roles: Ejecutor (económico, tareas mecánicas ya especificadas), Planificador (análisis, causa raíz, planes y diagnóstico de fallos) y Superior (diseño y estrategia ante decisiones nuevas). El mapeo a modelos concretos lo define el usuario.

Elige el recurso menos costoso que resuelva correctamente la tarea. Distingue el volumen de archivos de la complejidad cognitiva: una operación sobre muchos archivos puede seguir siendo mecánica.

| Tipo de trabajo | Recurso preferente |
|---|---|
| Listados, búsquedas, inventarios, formato, renombres o cambios repetitivos ya especificados | Herramientas deterministas; si requiere agente, Ejecutor con esfuerzo bajo |
| Cambios mecánicos coordinados, localización de referencias, refactorizaciones pequeñas delimitadas, correcciones simples o ejecución de un plan aprobado | Ejecutor con esfuerzo medio |
| Arquitectura, análisis transversal, causa raíz compleja, evaluación de alternativas, diseño de refactorización o migración, revisión técnica de impacto | Planificador con esfuerzo medio; Superior ante decisiones de diseño o estrategia nuevas |

- Prefiere comandos, búsquedas, Git, validadores, linters, tests y scripts deterministas cuando puedan resolver o comprobar una tarea.
- No selecciones un modelo de mayor capacidad solo por el número de archivos.
- Para trabajo complejo: usa el Planificador para diagnóstico y plan verificable; delega la ejecución mecánica definida al Ejecutor; vuelve al Planificador (o al Superior) solo ante una decisión nueva, ambigüedad importante o riesgo arquitectónico.
- Las tareas mecánicas previamente aprobadas pueden ejecutarse con el Ejecutor. Si aparece una condición no contemplada que afecte arquitectura, datos, seguridad, dependencias o persistencia, detén la ejecución y solicita o produce el análisis correspondiente.

## Comunicación de resultados

Al cerrar una tarea, informa de forma breve:

1. archivos inspeccionados o modificados;
2. validaciones realizadas y su alcance;
3. supuestos, riesgos o verificaciones pendientes.

Responde en español técnico claro, salvo que el usuario solicite otro idioma.
