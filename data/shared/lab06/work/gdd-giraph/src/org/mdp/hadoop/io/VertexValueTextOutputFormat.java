package org.mdp.hadoop.io;

import java.io.IOException;

import org.apache.giraph.graph.Vertex;
import org.apache.giraph.io.formats.TextVertexOutputFormat;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.Writable;
import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.mapreduce.TaskAttemptContext;

/**
 * Will write a graph to tsv where vertices are printed in the
 * first column, values in the second column, and edges are not printed
 * 
 * @author aidhog
 *
 */
public class VertexValueTextOutputFormat extends TextVertexOutputFormat<WritableComparable<?>, Writable, Writable> {
	
	private static final String SPLIT = "\t";
	  
	public VertexValueTextOutputFormat() {
		super();
	}

	@Override
	public TextVertexOutputFormat<WritableComparable<?>, Writable, Writable>.TextVertexWriter createVertexWriter(
			TaskAttemptContext arg0) throws IOException, InterruptedException {
		return new VertexValueTextWriter();
	}
	
	public class VertexValueTextWriter extends TextVertexWriterToEachLine  {
		@Override
		protected Text convertVertexToLine(Vertex<WritableComparable<?>, Writable, Writable> v) throws IOException {
			return new Text(v.getId()+SPLIT+v.getValue());
		}
	}
}
