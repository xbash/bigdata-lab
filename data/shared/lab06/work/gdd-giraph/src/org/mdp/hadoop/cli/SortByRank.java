package org.mdp.hadoop.cli;

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.GenericOptionsParser;

/**
 * Java class to sort PageRank results by rank (descending)
 * 
 * @author Aidan
 */
public class SortByRank {

	/**
	 * This is the Mapper Class. This sends key-value pairs to different machines
	 * based on the key.
	 * 
	 * Remember that the generic is Mapper<InputKey, InputValue, MapKey, MapValue>
	 * 
	 * InputKey we don't care about (a LongWritable will be passed as the input
	 * file offset, but we don't care; we can also set as Object)
	 * 
	 * InputValue will be Text: a line of the file
	 * 
	 * MapKey will be IntWritable: the numeric value
	 * 
	 * MapValue will be Text: the string value
	 * 
	 * @author Aidan
	 *
	 */
	public static class MapStringByDoubleValue extends 
		Mapper<Object, Text, DoubleWritable, Text>{

		/**
		 * @throws InterruptedException 
		 * 
		 * Each input line should be as follows:
		 * 
		 * string[\t]double
		 * 
		 * Parse this and map double as key, string as value.
		 * 
		 * Note DescendingDoubleWritable, which offers
		 * 	inverse sorting (largest first!)
		 * 
		 */
		@Override
		public void map(Object key, Text value, Context output)
						throws IOException, InterruptedException {
			String[] split = value.toString().split("\t");
			output.write(new DescendingDoubleWritable(Double.parseDouble(split[1])),new Text(split[0]));
		}
	}

	/**
	 * This is the Reducer Class.
	 * 
	 * This collects sets of key-value pairs with the same key on one machine. 
	 * 
	 * Remember that the generic is Reducer<MapKey, MapValue, OutputKey, OutputValue>
	 * 
	 * 		 
	 * MapKey will be Object
	 * 
	 * MapValue will be Object
	 * 
	 * OutputKey will be Object
	 * 
	 * OutputValue will be Object
	 * 
	 * @author Aidan
	 *
	 */
	public static class ReduceSwapKeyAndValue 
	       extends Reducer<Object, Object, Object, Object> {

		/**
		 * @throws InterruptedException 
		 * 
		 * The keys (counts) are called in descending order ...
		 * ... so for each value (word) of a key, we just write
		 * (value,key) pairs to the output and we're done.
		 * 
		 */
		@Override
		public void reduce(Object key, Iterable<Object> values,
				Context output) throws IOException, InterruptedException {
			for(Object value:values) {
				output.write(value,key);
			}
		}
	}

	/**
	 * Main method that sets up and runs the job
	 * 
	 * @param args First argument is input, second is output
	 * @throws Exception
	 */
	public static void main(String[] args) throws Exception {
		Configuration conf = new Configuration();
		String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs();
		if (otherArgs.length != 2) {
			System.err.println("Usage: "+SortByRank.class.getName()+" <in> <out>");
			System.exit(2);
		}
		String inputLocation = otherArgs[0];
		String outputLocation = otherArgs[1];

		Job job = Job.getInstance(new Configuration());
		job.setMapOutputKeyClass(DescendingDoubleWritable.class);
		job.setMapOutputValueClass(Text.class);
		job.setOutputKeyClass(Object.class);
		job.setOutputValueClass(Object.class);
		
		job.setMapperClass(MapStringByDoubleValue.class);
		job.setReducerClass(ReduceSwapKeyAndValue.class);

		FileInputFormat.setInputPaths(job, new Path(inputLocation));
		FileOutputFormat.setOutputPath(job, new Path(outputLocation));

		job.setJarByClass(SortByRank.class);
		job.waitForCompletion(true);
	}	
	
	/**
	 * A class that inverts the order for DoubleWritable objects so
	 * we can do a descending order.
	 * 
	 * @author ahogan
	 *
	 */
	public static class DescendingDoubleWritable extends DoubleWritable {
		
		public DescendingDoubleWritable(){}
		
		public DescendingDoubleWritable(double val){
			super(val);
		}
		
		public int compareTo(DoubleWritable o) {
			return -super.compareTo(o);
		}
	}
}
