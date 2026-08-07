package org.mdp.spark.cli;

import java.util.Locale;
import java.util.Set;
import java.util.TreeSet;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.storage.StorageLevel;

import scala.Tuple2;
import scala.Tuple3;

/**
 * Get summary information for TV series from IMDb:
 * best-rated episode(s), best episode rating and average episode rating.
 */
public class InfoSeriesRating {
	/**
	 * This will be called by spark
	 */
	public static void main(String[] args) {
		if(args.length != 2) {
			System.err.println("Usage arguments: inputPath outputPath");
			System.exit(0);
		}
		new InfoSeriesRating().run(args[0],args[1]);
	}

	/**
	 * The task body
	 */
	public void run(String inputFilePath, String outputFilePath) {
		SparkConf conf = new SparkConf()
				.setAppName(InfoSeriesRating.class.getName());
		JavaSparkContext context = new JavaSparkContext(conf);

		JavaRDD<Tuple3<String,String,Double>> seriesEpisodeRating = context.textFile(inputFilePath)
				.filter(line -> {
					String[] split = line.split("\t");
					return split.length >= 8 && split[6].equals("TV_SERIES") && !split[7].equals("null");
				})
				.map(line -> {
					String[] split = line.split("\t");
					return new Tuple3<String,String,Double>(
							split[3] + "#" + split[4],
							split[7],
							Double.parseDouble(split[2]));
				})
				.persist(StorageLevel.MEMORY_ONLY());

		JavaPairRDD<String, Double> seriesToEpisodeRating = seriesEpisodeRating.mapToPair(
				tup -> new Tuple2<String,Double>(tup._1(), tup._3()));

		JavaPairRDD<String, Tuple2<Double, Integer>> seriesToSumCountRating =
				seriesToEpisodeRating.aggregateByKey(
						new Tuple2<Double, Integer>(0d, 0),
						(sumCount, rating) ->
							new Tuple2<Double, Integer>(sumCount._1 + rating, sumCount._2 + 1),
						(sumCountA, sumCountB) ->
							new Tuple2<Double, Integer>(sumCountA._1 + sumCountB._1, sumCountA._2 + sumCountB._2));

		JavaPairRDD<String, Double> seriesToAvgRating = seriesToSumCountRating.mapToPair(
				tup -> new Tuple2<String,Double>(tup._1, tup._2._1 / tup._2._2));

		JavaPairRDD<String, Double> seriesToBestRating = seriesToEpisodeRating.reduceByKey(
				(ratingA, ratingB) -> Math.max(ratingA, ratingB));

		JavaPairRDD<String, Tuple2<String, Double>> seriesToEpisodeAndRating = seriesEpisodeRating.mapToPair(
				tup -> new Tuple2<String,Tuple2<String,Double>>(tup._1(), new Tuple2<String,Double>(tup._2(), tup._3())));

		JavaPairRDD<String, Set<String>> seriesToBestEpisodes = seriesToEpisodeAndRating.join(seriesToBestRating)
				.filter(tup -> Double.compare(tup._2._1._2, tup._2._2) == 0)
				.mapToPair(tup -> new Tuple2<String,String>(tup._1, tup._2._1._1))
				.aggregateByKey(
						new TreeSet<String>(),
						(episodes, episode) -> {
							episodes.add(episode);
							return episodes;
						},
						(episodesA, episodesB) -> {
							episodesA.addAll(episodesB);
							return episodesA;
						});

		JavaRDD<String> outputRDD = seriesToBestEpisodes.join(seriesToBestRating).join(seriesToAvgRating)
				.map(tup -> {
					Set<String> episodes = tup._2._1._1;
					Double bestRating = tup._2._1._2;
					Double avgRating = tup._2._2;
					return String.format(
							Locale.ROOT,
							"%s\t%s\t%.3f\t%.3f",
							tup._1,
							String.join("|", episodes),
							bestRating,
							avgRating);
				});

		outputRDD.saveAsTextFile(outputFilePath);

		context.close();
	}
}
