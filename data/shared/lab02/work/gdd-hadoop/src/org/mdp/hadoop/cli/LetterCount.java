package org.mdp.hadoop.cli;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

/**
 * Hadoop job that counts, for each alphabetic letter,
 * how many unique words contain that letter.
 */
public class LetterCount {
	
	public static class LetterCountMapper extends Mapper<Object, Text, Text, IntWritable> {
		private final IntWritable one = new IntWritable(1);
		private final Text letter = new Text();
		
		@Override
		public void map(Object key, Text value, Context context)
				throws IOException, InterruptedException {
			String line = value.toString();
			int separator = line.indexOf('\t');
			if (separator <= 0) {
				return;
			}
			
			String word = line.substring(0, separator);
			Set<Integer> seenLetters = new HashSet<Integer>();
			
			word.codePoints().forEach(codePoint -> {
				if (Character.isAlphabetic(codePoint)) {
					seenLetters.add(Integer.valueOf(codePoint));
				}
			});
			
			for (Integer codePoint : seenLetters) {
				letter.set(new String(Character.toChars(codePoint.intValue())));
				context.write(letter, one);
				context.getCounter("Letters", "Unique-word-letter-pairs").increment(1);
			}
		}
	}
	
	public static class LetterCountReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
		private final IntWritable count = new IntWritable(1);
		
		@Override
		public void reduce(Text key, Iterable<IntWritable> values, Context context)
				throws IOException, InterruptedException {
			int sum = 0;
			for (IntWritable value : values) {
				sum += value.get();
			}
			
			count.set(sum);
			context.write(key, count);
			context.getCounter("Letters", "Unique-output").increment(1);
		}
	}
	
	public static void main(String[] args) throws Exception {
		Configuration conf = new Configuration();
		
		String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs();
		if (otherArgs.length != 2) {
			System.err.println("Usage: LetterCount <in> <out>");
			System.exit(2);
		}
		String inputLocation = otherArgs[0];
		String outputLocation = otherArgs[1];
		
		Job job = Job.getInstance(conf, LetterCount.class.getName());
		job.setJarByClass(LetterCount.class);
		job.setMapperClass(LetterCountMapper.class);
		job.setCombinerClass(LetterCountReducer.class);
		job.setReducerClass(LetterCountReducer.class);
		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(IntWritable.class);
		job.setMapOutputKeyClass(Text.class);
		job.setOutputValueClass(IntWritable.class);
		FileInputFormat.addInputPath(job, new Path(inputLocation));
		FileOutputFormat.setOutputPath(job, new Path(outputLocation));
		System.exit(job.waitForCompletion(true) ? 0 : 1);
	}
}
