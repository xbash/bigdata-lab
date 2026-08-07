import org.apache.spark.SparkConf
import org.apache.spark.sql.SparkSession

// in spark shell, sc is defined for you
// val sc = new SparkContext(new SparkConf().setAppName("Scalalab5"))

// you can change this to run on the full data
val filein = "hdfs://cm:9000/uhadoop/shared/imdb/imdb-ratings-two.tsv"
val fileout = "hdfs://cm:9000/uhadoop2024/<user>/series-avg-two-sc/"

val input = sc.textFile(filein)
// to dump an RDD like input to the shell, use
//   input.collect()
// make sure not to do this for a large RDD
    
val lines = input.map(line => line.split("\t"))

val tvSeries = lines.filter(line => line(4) == "tvSeries" && line(5) != "null")

var seriesEpisodeRating = tvSeries.map(line => (line(2) + "#" + line(3), line(5), line(1).toFloat))

var seriesToEpisodeRating = seriesEpisodeRating.map(tup => (tup._1, tup._3))

var seriesToSumCountRating = seriesToEpisodeRating.aggregateByKey((0f, 0)) ((sumCount: (Float,Int), rating: Float) => (sumCount._1 + rating, sumCount._2 + 1), (sumCountA: (Float,Int), sumCountB: (Float,Int)) => (sumCountA._1 + sumCountB._1, sumCountA._2 + sumCountB._2) )

var seriesToAvgRating = seriesToSumCountRating.map(tup => (tup._1,tup._2._1/tup._2._2) )

seriesToAvgRating.saveAsTextFile(fileout)

sc.stop()

// to quit the shell:
//   :quit