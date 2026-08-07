# Instrucciones Lab 07

## 1. Levantar y Validar Cassandra
```powershell
powershell -ExecutionPolicy Bypass -File .\containers\scripts\up-cassandra.ps1
powershell -ExecutionPolicy Bypass -File .\containers\scripts\status-cassandra.ps1
```

## 2. Ejecutar Pruebas Lab 07
Ejemplo con parámetros personalizados:
```powershell
powershell -ExecutionPolicy Bypass -File .\containers\scripts\run-lab07-cassandra.ps1 `
  -Usuario "jperez" `
  -NombreIniciales "J. Perez" `
  -NombreCompleto "Juan Perez" `
  -Edad 31 `
  -ColorFav "black" `
  -PeliculaFav "Matrix" `
  -Comentario "lab07 prueba"
```

## Artefactos
El código CQL generado para revisión o entrega se encuentra en:
`data\shared\lab07\results\*-comandos-entrega.cql`
