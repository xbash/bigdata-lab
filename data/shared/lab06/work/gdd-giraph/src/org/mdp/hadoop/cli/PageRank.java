package org.mdp.hadoop.cli;

import java.io.IOException;

import org.apache.giraph.graph.BasicComputation;
import org.apache.giraph.graph.Vertex;
import org.apache.hadoop.io.DoubleWritable;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;

/**
 * A PageRank implementation for Giraph that supports nodes
 * with no outlinks.
 * 
 * Text: vertex ID type
 * DoubleWritable: vertex value
 * NullWritable: edge value
 * DoubleWritable: message type
 */
public class PageRank extends BasicComputation<Text, DoubleWritable, NullWritable, DoubleWritable> {
	// how many iterations to run (we will run ITERS + 3 supersteps,
	//   the first to activates all vertices, 
	//     the second to count them, 
	//        the last to apply final aggregation)
	public static final int ITERS = 10;
	
	// the damping factor (the probability to follow a link rather than randomly jump)
	public static final double D = 0.85;

	// the total rank delivered in the previous superstep
	public static final String RJ_AGG_NAME = "random_jump";

	// the total number of vertices (including without outlinks)
	public static final String NUM_V_NAME = "num_vertices";
	public static final IntWritable ONE = new IntWritable(1);



	/**
	 * This runs a "superstep" on a single vertex, where
	 * messages received from the previous superstep are
	 * read and processed, and messages for the next
	 * superstep are sent.
	 * 
	 * Superstep 0 sends dummy messages to activate all vertices.
	 * 
	 * Superstep 1 will count all vertices (including dangling ones).
	 * 
	 * Superstep 2 will send the first messages.
	 * 
	 * Supersteps 3 to ITER will compute new ranks and send messages.
	 * 
	 * Superstep ITER+2 will compute final ranks and halt vertices.
	 * 
	 * Text: the type of the vertex ID
	 * DoubleWritable: the type of the vertex value
	 * NullWritable: not used (can contain edge meta-data
	 *   like edge weights).
	 */
	@Override
	public void compute(Vertex<Text, DoubleWritable, NullWritable> vertex,
			Iterable<DoubleWritable> messages) throws IOException {
		if(getSuperstep() == 0) {
			// first superstep, "active" the vertices, including
			//   the dangling ones (without outlinks) 
			sendMessageToAllEdges(vertex, new DoubleWritable(0));
		} else if(getSuperstep() == 1) { 
			// second superstep, count the number of vertices
			aggregate(NUM_V_NAME,ONE);
		} else {
			int num_vertices = ((IntWritable)getAggregatedValue(NUM_V_NAME)).get();
			double currentRank = 0;

			if(getSuperstep() == 2) {
				// initial ranks of all vertices split evenly
				currentRank = (double) 1 / num_vertices;
				vertex.setValue(new DoubleWritable(currentRank));
			} else if(getSuperstep() >= 3) {
				// if in superstep 3 onwards, we compute the current rank
				// from incoming messages

				// first sum incoming messages from neighbours 
				for (DoubleWritable message : messages) {
					currentRank += message.get();
				}

				// further sum a constant rank associated with random jumps
				currentRank += ((DoubleWritable) getAggregatedValue(RJ_AGG_NAME)).get() / num_vertices;

				// set this sum as the new value/state for the vertex
				DoubleWritable dw = new DoubleWritable(currentRank);
				vertex.setValue(dw);
			}

			if(getSuperstep() == ITERS+2) {
				// if the last superstep, vote to end
				vertex.voteToHalt();
			} else if (getSuperstep() >= 2) {
				// if not the last superstep then we send messages to neighbours

				// get the outdegree of the current vertex
				long edges = vertex.getNumEdges();
				if(edges > 0) {
					// Split the damped rank evenly across outgoing edges.
					sendMessageToAllEdges(vertex, new DoubleWritable((D * currentRank) / edges));

					// Keep the non-damped remainder for the random jump term.
					aggregate(RJ_AGG_NAME, new DoubleWritable((1 - D) * currentRank));
				} else {
					// Dangling vertices contribute all their rank to the jump term.
					aggregate(RJ_AGG_NAME, new DoubleWritable(currentRank));
				}

			}
		}
	}
}
