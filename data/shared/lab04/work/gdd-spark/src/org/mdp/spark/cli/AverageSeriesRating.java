package org.mdp.spark.cli;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;

import scala.Tuple2;
import scala.Tuple3;

/**
 * Get the average ratings of TV series from IMDb.
 * 
 * This is the Java 8 version with lambda expressions.
 */
public class AverageSeriesRating {
	/**
	 * This will be called by spark
	 */
	public static void main(String[] args) {
		
		if(args.length != 2) {
			System.err.println("Usage arguments: inputPath outputPath");
			System.exit(0);
		}
		new AverageSeriesRating().run(args[0],args[1]);
	}

	/**
	 * The task body
	 */
	public void run(String inputFilePath, String outputFilePath) {
		/*
		 * Initialises a Spark context with the name of the application
		 *   and the (default) master settings.
		 */
		SparkConf conf = new SparkConf()
				.setAppName(AverageSeriesRating.class.getName());
		JavaSparkContext context = new JavaSparkContext(conf);

		/*
		 * Load the first RDD from the input location (a local file, HDFS file, etc.)
		 */
		JavaRDD<String> inputRDD = context.textFile(inputFilePath);
		
		/*
		 * Here we filter lines that are not TV series or where no episode name is given
		 */
		JavaRDD<String> tvSeries = inputRDD.filter(line -> {
			String[] split = line.split("\t");
			return split.length >= 8 && split[6].equals("TV_SERIES") && !split[7].equals("null");
		});
		
		/*
		 * We create a tuple (series,episode,rating) where series is the key (name+"#"+year+"#"+disambiguator)
		 */
		JavaRDD<Tuple3<String,String,Double>> seriesEpisodeRating = tvSeries.map(line -> {
			String[] split = line.split("\t");
			return new Tuple3<String,String,Double>(
					split[3] + "#" + split[4],
					split[7],
					Double.parseDouble(split[2]));
		});
		
		/*
		 * Now we start to compute the average rating per series.
		 * 
		 * We don't care about the episode name for now so to start with, 
		 * from tuples (series,episode,rating)
		 * we will produce a map: (series,rating)
		 * 
		 * (We could have done this directly from tvSeries, 
		 *   except seriesEpisodeRating will be reused later)
		 */
		JavaPairRDD<String,Double> seriesToEpisodeRating = seriesEpisodeRating.mapToPair(
				tup -> new Tuple2<String,Double>(tup._1(), tup._3()));
		
		/*
		 * To compute the average rating for each series, the idea is to
		 * maintain the following tuples:
		 * 
		 * (series,(sum,count))
		 * 
		 * Where series is the series identifier, 
		 *   count is the number of episode ratings thus far
		 *   sum is the sum of episode ratings thus far
		 *
		 * Base value: (0,0)
		 *
		 * To combine (sum, count) | rating:
		 *   (sum+rating,count+1)
		 *   
		 * To reduce (sum1,count1) | (sum2,count2)
		 *   (sum1+sum2,count1+count2)
		 */
		JavaPairRDD<String, Tuple2<Double, Integer>> seriesToSumCountRating = 
				seriesToEpisodeRating.aggregateByKey(
						new Tuple2<Double, Integer>(0d, 0), // base value
						(sumCount, rating) -> 
							new Tuple2<Double, Integer>(sumCount._1 + rating, sumCount._2 + 1 ), // combine function
						(sumCountA, sumCountB) -> 
							new Tuple2<Double, Integer>(sumCountA._1 + sumCountB._1, sumCountA._2 + sumCountB._2 )); // reduce function
		
		/*
		 * Given final values for:
		 * 
		 * (series,(sum,count))
		 * 
		 * Create the average:
		 * 
		 * (series,sum/count)
		 */
		JavaPairRDD<String,Double> seriesToAvgRating = seriesToSumCountRating.mapToPair(
				tup -> new Tuple2<String,Double>(tup._1, tup._2._1 / tup._2._2)
		);
		
		/*
		 * Write the output to local FS or HDFS
		 */
		seriesToAvgRating.saveAsTextFile(outputFilePath);
		
		context.close();
	}
}
