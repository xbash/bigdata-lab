# Instrucciones Lab 01

## 1. Prueba Controlada en Muestra (1k)
Valida la consistencia de rutas, logs y resultados.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab01\scripts\run_lab01_experiments.ps1 -UseSample -SkipInMemory -RunExternalPipeline -ExternalN 51 -Heap 1024M -BatchSize 10000 -TopK 20
```

*Nota: Para cambiar a top-100 usar `-TopK 100`.*
Las salidas quedan en:
- Resultados: `data/shared/lab01/results/`
- Logs: `data/shared/lab01/logs/`

## 2. Prueba en Memoria (Muestra 1k)
Confirma compilación Java y comportamiento del top-k. Ejecutar desde la raíz del proyecto.

### WordCount
```powershell
Push-Location .\data\shared\lab01\work\gdd_lab01\gdd-wiki
& "C:\apps-local\05-progra\java\jdk-jre-kit\jdk-21.0.10\bin\java.exe" -Xmx1024M -cp "bin;lib\commons-cli-1.1.jar" org.mdp.cli.Main RunWordCountInMemory -i "C:\rutinas-local\gen-container\bigdata-lab\data\shared\lab01\datasets\es-wiki-abstracts-1k.txt" -k 20 > "C:\rutinas-local\gen-container\bigdata-lab\data\shared\lab01\logs\wordcount_sample-1k_top20.stdout.txt" 2> "C:\rutinas-local\gen-container\bigdata-lab\data\shared\lab01\logs\wordcount_sample-1k_top20.stderr.log"
Pop-Location
```

### NGramCount (-n 2)
```powershell
Push-Location .\data\shared\lab01\work\gdd_lab01\gdd-wiki
& "C:\apps-local\05-progra\java\jdk-jre-kit\jdk-21.0.10\bin\java.exe" -Xmx1024M -cp "bin;lib\commons-cli-1.1.jar" org.mdp.cli.Main RunNGramCountInMemory -i "C:\rutinas-local\gen-container\bigdata-lab\data\shared\lab01\datasets\es-wiki-abstracts-1k.txt" -k 20 -n 2 > "C:\rutinas-local\gen-container\bigdata-lab\data\shared\lab01\logs\ngram_inmemory_sample-1k_n2_top20.stdout.txt" 2> "C:\rutinas-local\gen-container\bigdata-lab\data\shared\lab01\logs\ngram_inmemory_sample-1k_n2_top20.stderr.log"
Pop-Location
```

## 3. Corrida Completa del Pipeline Externo (n=51)
Ejecutar solo tras confirmar las pruebas anteriores.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab01\scripts\run_lab01_experiments.ps1 -SkipInMemory -RunExternalPipeline -ExternalN 51 -Heap 28G -BatchSize 500000 -TopK 100
```
