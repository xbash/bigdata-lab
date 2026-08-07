from __future__ import print_function

import sys
from pyspark.sql import SparkSession

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: average_series_rating.py <filein> <fileout>", file=sys.stderr)
        sys.exit(-1)

    filein = sys.argv[1]
    fileout = sys.argv[2]
    
    # in pyspark shell start with:
    #   filein = "hdfs://cm:9000/uhadoop/shared/imdb/imdb-ratings-two.tsv"
    #   fileout = "hdfs://cm:9000/uhadoop2025/<user>/series-avg-two-py/"
    # and continue line-by-line from here

    spark = SparkSession.builder.appName("AverageSeriesRating").getOrCreate()

    input = spark.read.text(filein).rdd.map(lambda r: r[0])
    # to dump an RDD like input to the pyspark shell, use
    #   input.collect()
    # make sure not to do this for a large RDD

    lines = input.map(lambda line: line.split("\t"))

    tvSeries = lines.filter(lambda line: ("tvSeries" == line[4]) and not ('null' == line[5]))

    seriesEpisodeRating = tvSeries.map(lambda line: (line[2]+ "#" + line[3], line[5], float(line[1])))

    seriesToEpisodeRating = seriesEpisodeRating.map(lambda tup: (tup[0], tup[2]))

    seriesToSumCountRating = seriesToEpisodeRating.aggregateByKey((0.0, 0), \
        lambda sumCount, rating: (sumCount[0] + rating, sumCount[1] + 1), \
        lambda sumCountA, sumCountB: (sumCountA[0] + sumCountB[0], sumCountA[1] + sumCountB[1]))

    seriesToAvgRating = seriesToSumCountRating.mapValues(lambda tup2n: tup2n[0]/tup2n[1])

    seriesToAvgRating.saveAsTextFile(fileout)

    spark.stop()