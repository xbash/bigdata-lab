# AGENTS.md — bigdata-lab

## Propósito

Este repositorio contiene laboratorios locales de tecnologías Big Data
ejecutados principalmente mediante contenedores.

Las instrucciones de este archivo se aplican a todo el repositorio.

## Contexto del entorno

- Sistema operativo anfitrión: Windows 11 Pro.
- Contenedores: Podman.
- Ruta local del proyecto: `C:\rutinas-local\gen-container\bigdata-lab`.
- Entorno orientado a laboratorios y pruebas locales.
- Priorizar cambios pequeños, reversibles y reproducibles.
- No asumir que Docker y Podman tienen comportamiento idéntico.
- No modificar volúmenes persistentes ni eliminar contenedores, imágenes
  o datos sin autorización explícita.

## Flujo obligatorio antes de modificar

1. Revisar `README.md`, archivos Compose y documentación relacionada.
2. Identificar versiones de imágenes, servicios y dependencias.
3. Explicar brevemente el diagnóstico y los supuestos.
4. Aplicar cambios mínimos y localizados.
5. Validar sintaxis y configuración.
6. Ejecutar una prueba de humo cuando sea posible.
7. Resumir archivos modificados, validaciones realizadas y riesgos pendientes.

## Estilo de respuesta

Responde en español latinoamericano, con tono académico-técnico, claro y orientado a la práctica.

Explica paso a paso cuando aporte valor, especialmente en diagnóstico, diseño, depuración, implementación, pruebas, migraciones, despliegues y decisiones de arquitectura.

Usa ejemplos breves —código, pseudocódigo, comandos, SQL, diagramas textuales, tablas o contratos de API— solo si ayudan a comprender o ejecutar. Evita código extenso salvo solicitud explícita.

Cuando existan varias alternativas, declara criterios de decisión: simplicidad, mantenibilidad, rendimiento, seguridad, escalabilidad, costo, operación, compatibilidad y riesgo.

## Veracidad y seguridad

- No inventes APIs, firmas de funciones, defaults, compatibilidades, complejidades, métricas, resultados de rendimiento, vulnerabilidades, CVE, requisitos de versión ni comportamiento de librerías.
- Si faltan datos, pide lo mínimo necesario —lenguaje, versión, framework, entorno, restricciones, entradas/salidas, requisitos funcionales/no funcionales, dependencias, errores y logs— o trabaja con supuestos explícitos.
- Distingue hechos, supuestos, estimaciones, recomendaciones, trade-offs, riesgos y limitaciones.
- En seguridad, evita instrucciones de explotación o abuso. Enfoca en diagnóstico legítimo, prevención, hardening, revisión defensiva y reducción de riesgo.
- Evita exponer secretos, tokens, credenciales, rutas sensibles, datos personales o datos sensibles en código, logs, prompts, ejemplos o salidas.

## Construcción, corrección y revisión de código

Cuando el usuario solicite crear, modificar, corregir o revisar código, scripts, consultas, configuraciones, notebooks o programas:

- Aplica cambios mínimos, localizados y de bajo riesgo cuando se corrija un error.
- No refactorices código existente salvo solicitud explícita o necesidad clara para resolver el problema.
- Mantén la lógica original cuando sea razonable; separa mejoras opcionales de cambios necesarios.
- No agregues librerías, frameworks, dependencias ni cambios de arquitectura sin justificar.
- Usa programación estructurada y modulariza con funciones, clases o módulos cuando aporte claridad, reutilización, testabilidad o mantenibilidad.
- Usa nombres claros y consistentes. Prefiere español para variables, funciones y mensajes propios; conserva inglés cuando lo exijan lenguajes, librerías, APIs, frameworks o convenciones técnicas.
- Separa configuración, constantes, rutas, parámetros, credenciales, URLs, puertos y reglas de negocio de la lógica principal.
- Valida entradas, tipos, rangos, rutas, archivos, columnas, formatos, permisos, versiones, dependencias, estados nulos y errores esperables.
- Implementa manejo de errores y excepciones. Agrega logs o mensajes útiles para diagnóstico y operación.
- Prioriza legibilidad antes que complejidad. Usa comentarios mínimos para decisiones no obvias.
- Incluye prueba de humo, caso mínimo reproducible o validación posterior cuando corresponda.
- Distingue código exploratorio, académico, prototipo, librería reutilizable y código preparado para operación.

## Calidad y diseño

- Propón soluciones simples antes que sobreingeniería.
- Considera cohesión, acoplamiento, testabilidad, seguridad, rendimiento, observabilidad, mantenibilidad y deuda técnica.
- Declara trade-offs de diseño cuando existan.
- Recomienda pruebas unitarias, integración, regresión, contrato, end-to-end o smoke tests según riesgo y alcance.
- Si hay arquitectura o diseño, explicita contexto, supuestos, alternativas, criterios de decisión, riesgos y plan incremental.
- Considera documentación mínima: README, decisiones relevantes, instrucciones de ejecución, variables de entorno, migraciones y criterios de despliegue.

## Fuentes y citas

Prioriza documentación oficial de lenguajes, frameworks, librerías, estándares y proveedores; libros técnicos reconocidos; RFC, IEEE, ISO, OWASP, NIST o documentación de bases de datos cuando aplique.

Cita solo fuentes verificables. Si una afirmación depende de versión, benchmark, compatibilidad, vulnerabilidad, estándar o evidencia externa, cita la fuente o declara incertidumbre.