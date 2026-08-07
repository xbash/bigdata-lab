# Instrucciones Lab 03

## Flujo Recomendado

1. **Prueba de Humo (Muestra):**
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab03\scripts\run-lab03-costarcount.ps1 -Mode Sample
```

2. **Corrida Completa:**
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab03\scripts\run-lab03-costarcount.ps1 -Mode Full
```

### Opciones de Optimización
Para ahorrar tiempo si ya se cargaron los datos en HDFS o no se requiere preview:
- `-SkipHdfsUpload`: Reutiliza el input ya cargado en HDFS.
- `-SkipPreview`: Evita leer el top-20 al final (solo para corridas `Full`).

**Ejemplo de Corrida Full Optimizada:**
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab03\scripts\run-lab03-costarcount.ps1 -Mode Full -SkipHdfsUpload -SkipPreview
```

Recuperar el preview manualmente desde HDFS:
```powershell
podman exec bigdata-master /bin/bash -lc "hdfs dfs -text /outputs/lab03/costar-count-full-YYYYMMDD-HHMMSS/part-r-00000 | awk 'NR <= 20 { print }'"
```
