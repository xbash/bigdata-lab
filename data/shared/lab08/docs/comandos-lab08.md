1. Descargar datos de Two and a Half Men desde TVMaze
En PowerShell o CMD:

```powershell
curl "https://api.tvmaze.com/singlesearch/shows?q=two%20and%20a%20half%20men" -o two-and-a-half-men.series.json
```

Para el equipo técnico, primero debes mirar el id de TVMaze dentro de two-and-a-half-men.series.json. Si prefieres verlo en consola:
curl "https://api.tvmaze.com/singlesearch/shows?q=two%20and%20a%20half%20men"

Luego, cuando ya sepas el id real de TVMaze de Two and a Half Men, descarga el crew:
curl "https://api.tvmaze.com/shows/130/crew" -o two-and-a-half-men.crew.json

2. Entrar a MongoDB

En la terminal donde corresponda:

```bash
mongo
```

3. Comandos iniciales del lab
Dentro de mongo:

```sql
show dbs
use tvdb
db
show collections
```

4. Consultas iniciales sobre series

```sql
db.series.find()
db.series.find().pretty()
db.series.countDocuments()
db.series.distinct("type")
```

5. Verificar si Two and a Half Men ya existe

```sql
db.series.find({ name: "Two and a Half Men" }).pretty()
```

Si no existe, cargarla:

```sql
var serie = cat("two-and-a-half-men.series.json")
db.series.insertOne(JSON.parse(serie))
```

Luego verificar inserción:

```sql
db.series.find({ name: "Two and a Half Men" }, { _id: 1, id: 1, name: 1 }).pretty()
```

6. Consultas de selección

db.series.find({ type: "Scripted" })
db.series.find({ genres: "Crime" })
db.series.find({ genres: { $all: ["Comedy", "Adventure"] } })
db.series.find({ "rating.average": { $gt: 9.3 } })
db.series.find({
  "rating.average": { $gt: 9.3 },
  $or: [{ genres: "Crime" }, { genres: "Comedy" }]
})
db.series.find({ genres: { $size: 2 } })

7. Proyecciones

db.series.find({ type: "Scripted" }, { _id: 0, name: 1, id: 1 })
db.series.find({ type: "Scripted" }, { _id: 0, name: 1 })
db.series.find({ type: "Scripted" }, { language: 0, id: 0 })
db.series.find({}, { _id: 0, name: 1, genres: { $slice: -1 } })

8. Agregaciones

db.series.aggregate([
  { $match: { language: "English" } },
  { $sort: { "rating.average": -1 } },
  { $project: { _id: 0, name: 1 } }
])

db.series.aggregate([
  { $unwind: "$genres" },
  { $group: { _id: "$genres", total: { $sum: 1 } } },
  { $sort: { total: -1, _id: 1 } }
])


9. Búsqueda de texto

db.series.createIndex({ summary: "text" })
db.series.find({ $text: { $search: "sociopathic grandfather" } })
db.series.find({ $text: { $search: "new york friends" } })


10. Obtener los identificadores reales de Two and a Half Men

id: el de TVMaze, viene dentro del documento.
_id: el ObjectId de MongoDB, se genera al insertar.

Consulta:

db.series.find({ name: "Two and a Half Men" }, { _id: 1, id: 1, name: 1 }).pretty()

11. Cargar el crew de Two and a Half Men

Si two-and-a-half-men.crew.json es pequeño:

var crewData = cat("two-and-a-half-men.crew.json")
db.crewTwoAndAHalfMen.insertMany(JSON.parse(crewData))

Si no, desde terminal del sistema usa:

mongoimport --db tvdb --collection crewTwoAndAHalfMen --file two-and-a-half-men.crew.json --jsonArray

12. Enlazar el crew con la serie Two and a Half Men
Reemplaza OBJECT_ID_DE_TWO_AND_A_HALF_MEN por el _id real que viste antes:

db.crewTwoAndAHalfMen.updateMany(
  {},
  { $set: { tvseries: ObjectId("OBJECT_ID_DE_TWO_AND_A_HALF_MEN") } }
)

13. Mover desde crewTwoAndAHalfMen hacia crew

db.crewTwoAndAHalfMen.aggregate([
  { $match: {} },
  {
    $merge: {
      into: "crew",
      whenMatched: "keepExisting",
      whenNotMatched: "insert"
    }
  }
])

db.crewTwoAndAHalfMen.drop()


14. Hacer el lookup para anidar el crew en Two and a Half Men
Reemplaza OBJECT_ID_DE_TWO_AND_A_HALF_MEN por el valor real:

```sql
db.series.aggregate([
  { $match: { _id: ObjectId("OBJECT_ID_DE_TWO_AND_A_HALF_MEN") } },
  {
    $lookup: {
      from: "crew",
      localField: "_id",
      foreignField: "tvseries",
      as: "crew"
    }
  }
]).pretty()
```

15. Salir

exit

Flujo mínimo recomendado para tu caso (Two and a Half Men)

1. En terminal:

curl "https://api.tvmaze.com/singlesearch/shows?q=two%20and%20a%20half%20men" -o two-and-a-half-men.series.json

2. En mongo:

use tvdb
db.series.find({ name: "Two and a Half Men" }).pretty()
var serie = cat("two-and-a-half-men.series.json")
db.series.insertOne(JSON.parse(serie))
db.series.find({ name: "Two and a Half Men" }, { _id: 1, id: 1, name: 1 }).pretty()

3. En terminal:

curl "https://api.tvmaze.com/shows/130/crew" -o two-and-a-half-men.crew.json

4. En mongo:

var crewData = cat("two-and-a-half-men.crew.json")
db.crewTwoAndAHalfMen.insertMany(JSON.parse(crewData))
db.crewTwoAndAHalfMen.updateMany({}, { $set: { tvseries: ObjectId("OBJECT_ID_DE_TWO_AND_A_HALF_MEN") } })
db.series.aggregate([
  { $match: { _id: ObjectId("OBJECT_ID_DE_TWO_AND_A_HALF_MEN") } },
  {
    $lookup: {
      from: "crew",
      localField: "_id",
      foreignField: "tvseries",
      as: "crew"
    }
  }
]).pretty()

Si quieres, en el siguiente mensaje te lo dejo como un único bloque limpio “para copiar y pegar”, separado en:
- Terminal del sistema
- Consola mongo
- Comandos con Two and a Half Men



















