# Instrucciones Lab 05

## 1. Levantar y Validar Overlay IR
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\containers\scripts\up-ir.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\containers\scripts\status-ir.ps1
```

## 2. Prueba de Humo (Indexación y Búsqueda sobre muestra)
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab05\scripts\run-lab05-index.ps1 -IndexName wiki-lab05-sample
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab05\scripts\run-lab05-search.ps1 -IndexName wiki-lab05-sample -Query trump
```

## 3. Corrida Final (Indexación Dataset Completo)
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab05\scripts\run-lab05-index.ps1 -InputLocalPath /opt/bigdata/data/shared/lab05/datasets/es-wiki-articles.tsv.gz -IndexName wiki-lab05-full
```

## 4. Consultas (Dataset Completo)
Ejecutar búsquedas (repetir variando `-Query` para "trump", "linux", "chile", "futbol", "python"):
```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab05\scripts\run-lab05-search.ps1 -IndexName wiki-lab05-full -Query trump
```

## Artefactos
Verificar en:
- `data/shared/lab05/logs/`
- `data/shared/lab05/results/`
