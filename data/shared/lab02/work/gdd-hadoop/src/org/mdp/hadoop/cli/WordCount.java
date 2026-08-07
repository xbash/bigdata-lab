package org.mdp.hadoop.cli;

import java.io.IOException;

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
 * Java class to run a remote Hadoop word count job.
 * 
 * Contains the main method, an inner Reducer class 
 * and an inner Mapper class.
 * 
 * @author Aidan
 */
public class WordCount {
	
	/**
	 * Use this with line.split(SPLIT_REGEX) to get fairly nice
	 * word splits.
	 */
	public static String SPLIT_REGEX = "[^\\p{L}']+";
	
	/**
	 * This is the Mapper Class. This sends key-value pairs to different machines
	 * based on the key.
	 * 
	 * Remember that the generic is Mapper<InputKey, InputValue, MapKey, MapValue>
	 * 
	 * InputKey we don't care about (a LongWritable will be passed as the input
	 * file offset in bytes, but we don't care; we can also set as Object)
	 * 
	 * InputValue will be Text: a line of the file
	 * 
	 * MapKey will be Text: a word from the file
	 * 
	 * MapValue will be IntWritable: a count: emit 1 for each occurrence of the word
	 * 
	 * @author Aidan
	 *
	 */
	public static class WordCountMapper extends Mapper<Object, Text, Text, IntWritable>{

		// in MapReduce, we need wrappers for common types
		private final IntWritable one = new IntWritable(1);
		private Text word = new Text();

		
		/**
		 * @throws InterruptedException 
		 * 
		 * This is the map method. A map can run on different machines on different
		 * parts of the input file.
		 * 
		 * This map class will take a line of text from the input, parse it into
		 * individual words, and omit pairs of the form (word,1). In this pair, word
		 * is considered a key. All pairs with a given word will then be sent to the
		 * same machine. Different words may be sent to different machines.
		 * 
		 * On the reduce side, we will gather all the pairs with a given word. We can
		 * then sum the values.
		 */
		@Override
		public void map(Object key, Text value, Context context)
						throws IOException, InterruptedException {
			// a line of the input file
			String line = value.toString();
			
			// split the line into individual words
			String[] rawWords = line.split(SPLIT_REGEX);
			
			// for each word
			for(String rawWord:rawWords) {
				// if the word is not an empty string
				if(!rawWord.isEmpty()){
					// lower case it
					word.set(rawWord.toLowerCase());
					
					// output a key with the word and the number 1
					context.write(word, one);
					
					// this counter will report at the end how many
					// words were written by the mapper
					context.getCounter("Words", "Non-unique-input").increment(1);
				}
			}
		}
	}

	/**
	 * This is the Reducer Class.
	 * 
	 * This collects sets of key-value pairs with the same key on one machine. 
	 * 
	 * Remember that the generic is Reducer<MapKey, MapValue, OutputKey, OutputValue>
	 * 
	 * MapKey will be Text: a word from the file
	 * 
	 * MapValue will be IntWritable: a count: emit 1 for each occurrence of the word
	 * 
	 * OutputKey will be Text: the same word
	 * 
	 * OutputValue will be IntWritable: the final count
	 * 
	 * @author Aidan
	 *
	 */
	public static class WordCountReducer extends Reducer<Text, IntWritable, Text, IntWritable> {

		// in MapReduce, we need wrappers for common types
		private final IntWritable count = new IntWritable(1);
		
		/**
		 * 
		 * This is the reduce method.
		 * 
		 * MapReduce will call this method once for each unique key and
		 * provide a list of all the values associated with that key.
		 * 
		 * In this case, the reduce method will be called once for each
		 * word, with a list of the counts of that word. The reducer will
		 * sum these values and output a single pair for each word:
		 * (word,sum)
		 * 
		 * Here, key is a word, values is a list of all the counts found for it.
		 * 
		 * @throws InterruptedException 
		 */
		@Override
		public void reduce(Text key, Iterable<IntWritable> values,
                Context context) throws IOException, InterruptedException {
			int sum = 0;
			
			// sum all the counts
			for (IntWritable val : values) {
				sum += val.get();
			}
			count.set(sum);
			
			// output a pair with the word and the count
			context.write(key, count);
			
			// this counter will report at the end how many
			// word counts were written by the reducer
			context.getCounter("Words", "Unique-output").increment(1);
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
		
		// get the command line arguments
		String[] otherArgs = new GenericOptionsParser(conf, args).getRemainingArgs();
		if (otherArgs.length != 2) {
			System.err.println("Usage: WordCount <in> <out>");
			System.exit(2);
		}
		String inputLocation = otherArgs[0];
		String outputLocation = otherArgs[1];
		
		// create a job instance with a name (in this case "WordClass")
		Job job = Job.getInstance(conf, WordCount.class.getName());
		
		// what is the main method to run
		job.setJarByClass(WordCount.class);
		
		// what is the mapper class
		job.setMapperClass(WordCountMapper.class);
		
		// what is the combiner class
		// (recall, a combiner is like a reducer that
		// acts over windows of the mapper output)
	    job.setCombinerClass(WordCountReducer.class);
	    
	    
	    // what is the reducer class
	    job.setReducerClass(WordCountReducer.class);
	    
	    // what is the reducer output type
	    job.setOutputKeyClass(Text.class);
	    job.setOutputValueClass(IntWritable.class);
	    
	    // what is the map output type
	    job.setMapOutputKeyClass(Text.class);
	    job.setOutputValueClass(IntWritable.class);
	    
	    // pass the input and output locations
	    FileInputFormat.addInputPath(job, new Path(inputLocation));
	    FileOutputFormat.setOutputPath(job, new Path(outputLocation));
	    
	    // wait for the job to finish and exit
	    // with the same code returned (0 success, 1 fail)
	    System.exit(job.waitForCompletion(true) ? 0 : 1);
	}	
}
