1. Descargar datos de Friends desde TVMaze
En PowerShell o CMD:

```powershell
curl "https://api.tvmaze.com/singlesearch/shows?q=friends" -o friends.json
```

Para el equipo técnico, primero debes mirar el id de TVMaze dentro de friends.json. Si prefieres verlo en consola:
curl "https://api.tvmaze.com/singlesearch/shows?q=friends"

Luego, cuando ya sepas el id real de TVMaze de Friends, descarga el crew:
curl "https://api.tvmaze.com/shows/ID_TVMAZE_FRIENDS/crew" -o friends-crew.json

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

5. Verificar si Friends ya existe

```sql
db.series.find({ name: "Friends" }).pretty()
```

Si no existe, cargarla:

```sql
var serie = cat("friends.json")
db.series.insertOne(JSON.parse(serie))
```

Luego verificar inserción:

```sql
db.series.find({ name: "Friends" }, { _id: 1, id: 1, name: 1 }).pretty()
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


10. Obtener los identificadores reales de Friends

id: el de TVMaze, viene dentro del documento.
_id: el ObjectId de MongoDB, se genera al insertar.

Consulta:

db.series.find({ name: "Friends" }, { _id: 1, id: 1, name: 1 }).pretty()

11. Cargar el crew de Friends

Si friends-crew.json es pequeño:

var crewData = cat("friends-crew.json")
db.crewFriends.insertMany(JSON.parse(crewData))

Si no, desde terminal del sistema usa:

mongoimport --db tvdb --collection crewFriends --file friends-crew.json --jsonArray

12. Enlazar el crew con la serie Friends
Reemplaza OBJECT_ID_DE_FRIENDS por el _id real que viste antes:

db.crewFriends.updateMany(
  {},
  { $set: { tvseries: ObjectId("OBJECT_ID_DE_FRIENDS") } }
)

13. Mover desde crewFriends hacia crew

db.crewFriends.aggregate([
  { $match: {} },
  {
    $merge: {
      into: "crew",
      whenMatched: "keepExisting",
      whenNotMatched: "insert"
    }
  }
])

db.crewFriends.drop()


14. Hacer el lookup para anidar el crew en Friends
Reemplaza OBJECT_ID_DE_FRIENDS por el valor real:

```sql
db.series.aggregate([
  { $match: { _id: ObjectId("OBJECT_ID_DE_FRIENDS") } },
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

Flujo mínimo recomendado para tu caso (Friends)

1. En terminal:

curl "https://api.tvmaze.com/singlesearch/shows?q=friends" -o friends.json

2. En mongo:

use tvdb
db.series.find({ name: "Friends" }).pretty()
var serie = cat("friends.json")
db.series.insertOne(JSON.parse(serie))
db.series.find({ name: "Friends" }, { _id: 1, id: 1, name: 1 }).pretty()

3. En terminal:

curl "https://api.tvmaze.com/shows/ID_TVMAZE_FRIENDS/crew" -o friends-crew.json

4. En mongo:

var crewData = cat("friends-crew.json")
db.crewFriends.insertMany(JSON.parse(crewData))
db.crewFriends.updateMany({}, { $set: { tvseries: ObjectId("OBJECT_ID_DE_FRIENDS") } })
db.series.aggregate([
  { $match: { _id: ObjectId("OBJECT_ID_DE_FRIENDS") } },
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
- Comandos con Friends



















