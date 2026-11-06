# Instrucciones Lab 06

## 1. Preparación
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab06\scripts\prepare-lab06.ps1
```

## 2. Prueba de Humo (Muestra)
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab06\scripts\run-lab06-pagerank.ps1
```

## 3. Corrida Completa (es-wiki-links.tsv.gz)
Asegurar que el overlay IR esté abajo (bajarlo con `down-ir.ps1`). Perfil conservador validado:
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab06\scripts\run-lab06-pagerank.ps1 `
  -InputLocalPath /opt/bigdata/data/shared/lab06/datasets/es-wiki-links.tsv.gz `
  -InputHdfsPath /inputs/lab06/es-wiki-links.tsv.gz `
  -Workers 1 `
  -MapMemoryMb 4096 `
  -MapJavaOpts "-Xmx3276m"
```
*Si hay errores de memoria (Exit 137), incrementar RAM de la VM o evaluar aumentar los workers solo tras asegurar memoria física disponible.*

## Artefactos
Revisar resultados en `logs/` y `results/`. 
Validación HDFS:
```powershell
podman exec bigdata-master hdfs dfs -ls /outputs/lab06
```
