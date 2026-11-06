# Lab 08 - MongoDB

Archivo de apoyo para dejar los comandos del laboratorio en un formato limpio,
ordenado y facil de copiar.

Supuesto explicitado:
- La serie elegida desde el inicio es `Two and a Half Men`.

Importante:
- El enunciado pide entregar a U-Cursos un archivo de texto con los comandos
  usados en MongoDB.
- Este archivo tambien separa los comandos que deben ejecutarse en la terminal
  del sistema porque el laboratorio requiere obtener JSON desde TVMaze y, si
  hiciera falta, importar el arreglo de `crew` con `mongoimport`.
- Antes de insertar `Two and a Half Men`, conviene verificar si ya existe en `db.series`.

## Terminal del sistema

```powershell
curl "https://api.tvmaze.com/singlesearch/shows?q=two%20and%20a%20half%20men" -o two-and-a-half-men.series.json
curl "https://api.tvmaze.com/singlesearch/shows?q=two%20and%20a%20half%20men"
curl "https://api.tvmaze.com/shows/130/crew" -o two-and-a-half-men.crew.json
mongo
```

## Consola mongo

```javascript
show dbs
use tvdb
db
show collections

db.series.find()
db.series.find().pretty()
db.series.countDocuments()
db.series.distinct("type")

db.series.find({ type: "Scripted" })
db.series.find({ genres: "Crime" })
db.series.find({ genres: { $all: ["Comedy", "Adventure"] } })
db.series.find({ "rating.average": { $gt: 9.3 } })
db.series.find({
  "rating.average": { $gt: 9.3 },
  $or: [{ genres: "Crime" }, { genres: "Comedy" }]
})
db.series.find({ genres: { $size: 2 } })

db.series.find({ type: "Scripted" }, { _id: 0, name: 1, id: 1 })
db.series.find({ type: "Scripted" }, { _id: 0, name: 1 })
db.series.find({ type: "Scripted" }, { language: 0, id: 0 })
db.series.find({}, { _id: 0, name: 1, genres: { $slice: -1 } })

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

db.series.createIndex({ summary: "text" })
db.series.find({ $text: { $search: "sociopathic grandfather" } })
db.series.find({ $text: { $search: "new york friends" } })
```

## Comandos con Two and a Half Men

```javascript
db.series.find({ name: "Two and a Half Men" }).pretty()

var serie = cat("two-and-a-half-men.series.json")
db.series.insertOne(JSON.parse(serie))

db.series.find({ name: "Two and a Half Men" }, { _id: 1, id: 1, name: 1 }).pretty()

var crewData = cat("two-and-a-half-men.crew.json")
db.crewTwoAndAHalfMen.insertMany(JSON.parse(crewData))

db.crewTwoAndAHalfMen.updateMany(
  {},
  { $set: { tvseries: ObjectId("AQUI_REEMPLAZAR_POR_EL_OBJECT_ID_REAL_DE_TWO_AND_A_HALF_MEN") } }
)

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

db.series.aggregate([
  { $match: { _id: ObjectId("AQUI_REEMPLAZAR_POR_EL_OBJECT_ID_REAL_DE_TWO_AND_A_HALF_MEN") } },
  {
    $lookup: {
      from: "crew",
      localField: "_id",
      foreignField: "tvseries",
      as: "crew"
    }
  }
]).pretty()

exit
```

## Alternativa si el arreglo de crew fuera demasiado grande

Este comando no va en la consola de MongoDB sino en la terminal del sistema:

```powershell
mongoimport --db tvdb --collection crewTwoAndAHalfMen --file two-and-a-half-men.crew.json --jsonArray
```

## Nota para dejarlo listo como entrega final

Antes de subirlo:
- reemplaza `AQUI_REEMPLAZAR_POR_EL_OBJECT_ID_REAL_DE_TWO_AND_A_HALF_MEN` por el valor real
  obtenido desde `db.series.find({ name: "Two and a Half Men" }, { _id: 1, id: 1, name: 1 }).pretty()`
- si `Two and a Half Men` ya existia en la base, no repitas `insertOne`; en ese caso usa el
  documento existente y continua con la carga de `crew`
