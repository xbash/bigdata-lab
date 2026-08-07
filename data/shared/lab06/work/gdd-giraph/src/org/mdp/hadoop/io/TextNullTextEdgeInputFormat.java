package org.mdp.hadoop.io;

import java.io.IOException;
import java.util.ArrayList;

import org.apache.giraph.io.EdgeReader;
import org.apache.giraph.io.formats.TextEdgeInputFormat;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.InputSplit;
import org.apache.hadoop.mapreduce.TaskAttemptContext;

/**
 * Will read a graph from tsv where vertices are strings
 * and each line is a tsv-separated pair of vertices (a directed edge)
 * 
 * @author aidhog
 *
 */
public class TextNullTextEdgeInputFormat extends TextEdgeInputFormat<Text, NullWritable> {
	
	private static final String SPLIT = "\t";
	  
	public TextNullTextEdgeInputFormat() {
		super();
	}

	@Override
	public EdgeReader<Text, NullWritable> createEdgeReader(InputSplit is, TaskAttemptContext tac) throws IOException {
		return new TextNullTextEdgeReader();
	}
	
	public class TextNullTextEdgeReader extends TextEdgeReaderFromEachLineProcessed<ArrayList<String>> {
		@Override
		protected Text getSourceVertexId(ArrayList<String> al) throws IOException {
			return new Text(al.get(0));
		}

		@Override
		protected Text getTargetVertexId(ArrayList<String> al) throws IOException {
			return new Text(al.get(1));
		}

		@Override
		protected NullWritable getValue(ArrayList<String> arg0) throws IOException {
			return NullWritable.get();
		}

		@Override
		protected ArrayList<String> preprocessLine(Text t) throws IOException {
			String[] split = t.toString().split(SPLIT);
			ArrayList<String> list = new ArrayList<String>();
			if(split.length>=2) {
				list.add(split[0]);
				list.add(split[1]);
			} else {
				throw new IOException("Error reading line "+t.toString()+". Expecting tab-separated pair of strings.");
			}
			return list;
		}
	}
}
