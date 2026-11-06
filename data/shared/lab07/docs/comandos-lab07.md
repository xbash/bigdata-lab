# Comandos Lab 07 - Cassandra

Resumen de comandos a ingresar para replicar el laboratorio `lab07`,
asumiendo `usuario = grupo4`.

## 1. Comandos de terminal previos

Levantar y validar Cassandra desde este checkout:

```powershell
powershell -ExecutionPolicy Bypass -File .\containers\scripts\up-cassandra.ps1
powershell -ExecutionPolicy Bypass -File .\containers\scripts\status-cassandra.ps1
```

Entrar al cliente CQL:

```powershell
cqlsh 10.10.10.1
```

Comandos opcionales de diagnostico del cluster:

```powershell
nodetool status
nodetool -h 10.10.10.1 info
nodetool -h 10.10.10.12 info
nodetool -h 10.10.10.13 info
nodetool -h 10.10.10.14 info
nodetool -h 10.10.10.15 info
```

Si `cqlsh` reporta error de conexion, el PDF indica intentar:

```powershell
/data/hadoop/cassandra/bin/nodetool enablethrift
```

## 2. Comandos dentro de `cqlsh`

### 2.1. Crear y borrar keyspace propio de practica

```sql
CREATE KEYSPACE grupo4
WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 3};

DESCRIBE keyspaces;

USE grupo4;
```

Intento sin llave primaria, para evidenciar el error del laboratorio:

```sql
CREATE TABLE grupo4_tmp (
  usuario text,
  edad int
);
```

Creacion correcta de la tabla:

```sql
CREATE TABLE grupo4_tmp (
  usuario text PRIMARY KEY,
  edad int
);

DESCRIBE tables;

ALTER TABLE grupo4_tmp ADD viva boolean;

DROP TABLE grupo4_tmp;

DROP KEYSPACE grupo4;
```

### 2.2. Ir al keyspace comun y explorar datos

```sql
USE cc66i;

DESCRIBE tables;

SELECT * FROM alumno;
```

### 2.3. Insertar y actualizar fila propia en `alumno`

Insertar iniciales:

```sql
INSERT INTO alumno (usuario, nombre) VALUES ('grupo4', 'G. Cuadro');

SELECT * FROM alumno;
```

Intento con tipo incorrecto, para evidenciar el error:

```sql
INSERT INTO alumno (usuario, nombre) VALUES ('grupo4', true);
```

Sobrescribir con nombre completo:

```sql
INSERT INTO alumno (usuario, nombre) VALUES ('grupo4', 'Grupo Cuatro');
```

Intento incorrecto sin llave:

```sql
INSERT INTO alumno (edad) VALUES (38);
```

Insercion correcta de edad:

```sql
INSERT INTO alumno (usuario, edad) VALUES ('grupo4', 38);
```

Completar el resto de los datos:

```sql
INSERT INTO alumno (usuario, color_fav) VALUES ('grupo4', 'blue');
INSERT INTO alumno (usuario, pelicula_fav) VALUES ('grupo4', 'Arrival');
INSERT INTO alumno (usuario, comentario) VALUES ('grupo4', 'ejecucion local');
INSERT INTO alumno (usuario, despierto) VALUES ('grupo4', true);
```

Verificar resultado:

```sql
SELECT * FROM alumno;
```

### 2.4. Consultas pedidas sobre `alumno`

```sql
SELECT COUNT(*) AS count FROM alumno;

SELECT nombre FROM alumno WHERE usuario = 'grupo4';

SELECT nombre FROM alumno WHERE edad = 38;
```

La ultima consulta debe fallar antes de crear un indice.

### 2.5. Copia personal de la tabla y carga en tabla propia

Exportar a CSV:

```sql
COPY alumno (
  usuario,
  color_fav,
  comentario,
  despierto,
  edad,
  nombre,
  pelicula_fav
) TO '/camino/a/tu/carpeta/grupo4.csv';
```

Si quieres revisar el archivo y volver a entrar:

```sql
exit
```

```powershell
more grupo4.csv
cqlsh 10.10.10.1 9160
```

```sql
USE cc66i;
```

Crear copia personal de la tabla:

```sql
CREATE TABLE grupo4 (
  usuario text PRIMARY KEY,
  color_fav text,
  comentario text,
  despierto boolean,
  edad int,
  nombre text,
  pelicula_fav text
);
```

Cargar datos desde CSV:

```sql
COPY grupo4 (
  usuario,
  color_fav,
  comentario,
  despierto,
  edad,
  nombre,
  pelicula_fav
) FROM '/camino/a/tu/carpeta/grupo4.csv';
```

### 2.6. Crear indice y repetir consultas

```sql
CREATE INDEX edadIndex_grupo4 ON grupo4 (edad);

SELECT nombre FROM grupo4 WHERE edad = 38;

SELECT nombre FROM grupo4 WHERE edad = 38 AND despierto = true;

SELECT nombre FROM grupo4 WHERE edad > 25;
```

Notas:

- La consulta `edad = 38 AND despierto = true` puede requerir `ALLOW FILTERING`
  si no existe un indice adicional para `despierto`.
- La consulta `edad > 25` normalmente genera `warning` o requiere
  `ALLOW FILTERING`, tal como anticipa el enunciado.

Versiones tipicas para probar esas variantes:

```sql
SELECT nombre FROM grupo4 WHERE edad = 38 AND despierto = true ALLOW FILTERING;

SELECT nombre FROM grupo4 WHERE edad > 25 ALLOW FILTERING;
```

### 2.7. Tabla final con clave primaria para consultas sin warning

Crear tabla orientada a consulta:

```sql
CREATE TABLE grupo4_por_color (
  color_fav text,
  edad int,
  usuario text,
  comentario text,
  despierto boolean,
  nombre text,
  pelicula_fav text,
  PRIMARY KEY ((color_fav), edad, usuario)
);
```

Insertar al menos la fila propia:

```sql
INSERT INTO grupo4_por_color (
  color_fav,
  edad,
  usuario,
  comentario,
  despierto,
  nombre,
  pelicula_fav
) VALUES (
  'blue',
  38,
  'grupo4',
  'ejecucion local',
  true,
  'Grupo Cuatro',
  'Arrival'
);
```

Consultas finales pedidas:

```sql
SELECT * FROM grupo4_por_color WHERE color_fav = 'black';

SELECT * FROM grupo4_por_color WHERE color_fav = 'black' AND edad > 20;

SELECT * FROM grupo4_por_color
WHERE color_fav = 'black' AND usuario = 'amoya' AND edad = 37;
```

Para probar con la fila propia realmente insertada:

```sql
SELECT * FROM grupo4_por_color WHERE color_fav = 'blue';

SELECT * FROM grupo4_por_color WHERE color_fav = 'blue' AND edad > 20;

SELECT * FROM grupo4_por_color
WHERE color_fav = 'blue' AND usuario = 'grupo4' AND edad = 38;
```

### 2.8. Salida

```sql
exit
```

## 3. Observaciones metodologicas

- Este archivo resume los comandos pedidos por el PDF y adapta el identificador
  `usuario` a `grupo4`.
- Algunas instrucciones del enunciado estan pensadas para producir error o
  warning; por eso se incluyen igual.
- Los paths de `COPY ... TO/FROM` deben ajustarse a una ruta real accesible
  desde el entorno donde corra `cqlsh`.
