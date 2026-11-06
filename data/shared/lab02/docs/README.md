# Instrucciones Lab 02

## 1. Compilación del código fuente (`gdd-hadoop.jar`)

### Alternativa 1: Ant
```powershell
Push-Location .\data\shared\lab02\work\gdd-hadoop
ant clean > ..\..\logs\lab02-ant-clean.stdout.txt 2> ..\..\logs\lab02-ant-clean.stderr.log
ant dist > ..\..\logs\lab02-ant-dist.stdout.txt 2> ..\..\logs\lab02-ant-dist.stderr.log
Pop-Location
```

### Alternativa 2: Javac + Jar
```powershell
Push-Location .\data\shared\lab02\work\gdd-hadoop
Remove-Item .\bin, .\dist -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path .\bin, .\dist | Out-Null

& "C:\apps-local\05-progra\java\jdk-jre-kit\jdk-21.0.10\bin\javac.exe" --release 8 -cp ".\lib\commons-cli-1.1.jar;.\lib\commons-logging-1.1.3.jar;.\lib\hadoop-common-2.3.0.jar;.\lib\hadoop-mapreduce-client-core-2.3.0.jar" -d .\bin .\src\org\mdp\hadoop\cli\Main.java .\src\org\mdp\hadoop\cli\WordCount.java .\src\org\mdp\hadoop\cli\LetterCount.java > ..\logs\lab02-javac.stdout.txt 2> ..\logs\lab02-javac.stderr.log

& "C:\apps-local\05-progra\java\jdk-jre-kit\jdk-21.0.10\bin\jar.exe" cfe .\dist\gdd-hadoop.jar org.mdp.hadoop.cli.Main -C .\bin . > ..\logs\lab02-jar.stdout.txt 2> ..\logs\lab02-jar.stderr.log
Pop-Location
```
Verificar artefacto: `Get-Item .\data\shared\lab02\work\gdd-hadoop\dist\gdd-hadoop.jar`

## 2. Ejecución con Scripts Operativos

Ejecuta ambos pasos seguidos capturando la ruta HDFS de WordCount automáticamente:

```powershell
$wordcountOutput = powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab02\scripts\run-lab02-wordcount.ps1
$wordcountOutput | ForEach-Object { $_ }

$wordcountHdfsPath = $wordcountOutput | Select-String '^Resultado HDFS:\s*(.+)$' | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() } | Select-Object -First 1

if (-not $wordcountHdfsPath) { throw "Error capturando HDFS path" }

powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\data\shared\lab02\scripts\run-lab02-lettercount.ps1 -WordCountInputHdfsPath $wordcountHdfsPath
```

## 3. Cierre y Extracción Académica (A-Z)
Extraer solo caracteres a-z para la entrega final:
```powershell
Get-Content .\data\shared\lab02\logs\*-lettercount-results.txt | Where-Object { $_ -match '^[a-z]\s+' } | Set-Content .\data\shared\lab02\results\lettercount-a-z.txt
```
