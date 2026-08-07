# Instrucciones Lab 04

## 1. Prueba Pequeña (Muestra)
Valida `InfoSeriesRating` con el dataset de ejemplo:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab04\scripts\run-lab04.ps1 -Utility InfoSeriesRating -InputLocalPath /opt/bigdata/data/shared/lab04/datasets/imdb-ratings-two.tsv
```

## 2. Corrida Final (Completa)
Ejecuta `InfoSeriesRating` con el dataset completo:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab04\scripts\run-lab04.ps1 -Utility InfoSeriesRating -InputLocalPath /opt/bigdata/data/shared/lab04/datasets/imdb-ratings.tsv
```

## Artefactos Esperados
Las salidas se guardarán en `data/shared/lab04/logs/` y `data/shared/lab04/results/`.
Para entrega académica, conservar:
- Log de ejecución
- Preview del top20
- Ruta HDFS
- Las tuplas esperadas ("American Crime Story#2016" y otra de elección).
