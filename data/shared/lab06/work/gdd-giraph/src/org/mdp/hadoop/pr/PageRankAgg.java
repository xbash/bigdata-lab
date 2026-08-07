package org.mdp.hadoop.pr;

import org.apache.giraph.aggregators.DoubleSumAggregator;
import org.apache.giraph.aggregators.IntSumAggregator;
import org.apache.giraph.master.DefaultMasterCompute;
import org.mdp.hadoop.cli.PageRank;

public class PageRankAgg extends DefaultMasterCompute {
	public void initialize() throws InstantiationException, IllegalAccessException {
		registerAggregator(PageRank.RJ_AGG_NAME, DoubleSumAggregator.class);
		registerPersistentAggregator(PageRank.NUM_V_NAME, IntSumAggregator.class);
	}
}
