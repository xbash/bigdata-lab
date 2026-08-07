package cl.uchile.pmd;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.rmi.AlreadyBoundException;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.transport.TransportClient;
import org.elasticsearch.index.query.MultiMatchQueryBuilder;
import org.elasticsearch.index.query.QueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.index.query.functionscore.FieldValueFactorFunctionBuilder;
import org.elasticsearch.index.query.functionscore.FunctionScoreQueryBuilder;
import org.elasticsearch.index.query.functionscore.ScoreFunctionBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.common.lucene.search.function.CombineFunction;

/**
 * Main method to search articles using Elasticsearch.
 * 
 * @author Aidan, Alberto
 */
public class SearchWikiIndex {

	// used to assign higher/lower ranking
	// weight to different document fields
	public static final Map<String, Float> BOOSTS = new HashMap<>();
	static {
		BOOSTS.put(BuildWikiIndexBulk.FieldNames.ABSTRACT.name(), 1f); // <- default
		BOOSTS.put(BuildWikiIndexBulk.FieldNames.TITLE.name(), 5f);
	}

	public static final int DOCS_PER_PAGE = 10;

	public static void main(String args[]) throws IOException, ClassNotFoundException, AlreadyBoundException,
			InstantiationException, IllegalAccessException {
		Option inO = new Option("i", "input elasticsearch index name");
		inO.setArgs(1);
		inO.setRequired(true);

		Option rankedO = new Option("ranked", "combine the textual score with the stored PageRank field");
		rankedO.setArgs(0);

		Option rankFactorO = new Option("rf", "factor used when adding the stored PageRank to the textual score");
		rankFactorO.setArgs(1);

		Option showRankO = new Option("showrank", "append the stored PageRank value to the output");
		showRankO.setArgs(0);

		Option showScoreO = new Option("showscore", "append the Elasticsearch score to the output");
		showScoreO.setArgs(0);

		Option helpO = new Option("h", "print help");
		helpO.setArgs(0);

		Options options = new Options();
		options.addOption(inO);
		options.addOption(rankedO);
		options.addOption(rankFactorO);
		options.addOption(showRankO);
		options.addOption(showScoreO);
		options.addOption(helpO);

		CommandLineParser parser = new DefaultParser();
		CommandLine cmd = null;

		try {
			cmd = parser.parse(options, args);
		} catch (ParseException e) {
			System.err.println("***ERROR: " + e.getClass() + ": " + e.getMessage());
			HelpFormatter formatter = new HelpFormatter();
			formatter.printHelp("parameters:", options);
			return;
		}

		// print help options and return
		if (cmd.hasOption("h")) {
			HelpFormatter formatter = new HelpFormatter();
			formatter.printHelp("parameters:", options);
			return;
		}

		TransportClient client = ElasticsearchCluster.getTransportClient();
		
		String indexName = cmd.getOptionValue(inO.getOpt());
		System.err.println("Querying index at  " + indexName);
		boolean useRank = cmd.hasOption(rankedO.getOpt());
		boolean showRank = cmd.hasOption(showRankO.getOpt());
		boolean showScore = cmd.hasOption(showScoreO.getOpt());
		float rankFactor = Float.parseFloat(cmd.getOptionValue(rankFactorO.getOpt(), "1000"));

		startSearchApp(client, indexName, useRank, rankFactor, showRank, showScore);
		
		client.close();
	}

	/**
	 * 
	 * @param inDirectory : the location of the index directory
	 * @throws IOException
	 */
	public static void startSearchApp(TransportClient client, String indexName, boolean useRank, float rankFactor,
			boolean showRank, boolean showScore) throws IOException {
		// we open a UTF-8 reader over std-in
		BufferedReader br = new BufferedReader(new InputStreamReader(System.in, "utf-8"));

		while (true) {
			System.out.println("Enter a keyword search phrase:");

			// read keyword search from user
			String line = br.readLine();
			if (line == null) {
				break;
			}

			line = line.trim();
			if (!line.isEmpty()) {
				try {
					// we will use a multi-match query builder that
					// will allow us to match multiple document fields
					// (e.g., search over title and abstract)
					MultiMatchQueryBuilder multiMatchQueryBuilder = QueryBuilders.multiMatchQuery(line,
							BuildWikiIndexBulk.FieldNames.TITLE.name(), BuildWikiIndexBulk.FieldNames.ABSTRACT.name()).fields(BOOSTS);
					QueryBuilder query = multiMatchQueryBuilder;
					if (useRank) {
						FieldValueFactorFunctionBuilder rankFunction = ScoreFunctionBuilders
								.fieldValueFactorFunction(BuildWikiIndexBulk.FieldNames.RANK.name())
								.factor(rankFactor)
								.missing(0d);
						FunctionScoreQueryBuilder rankAwareQuery = QueryBuilders.functionScoreQuery(query, rankFunction);
						rankAwareQuery.boostMode(CombineFunction.SUM);
						query = rankAwareQuery;
					}

					// here we run the search, specifying how many results
					// we want per "page" of results
					SearchResponse response = client.prepareSearch(indexName).setQuery(query) // Query
							.setSize(DOCS_PER_PAGE).setExplain(true).get();
					
					// for each document in the results ...
					for (SearchHit hit : response.getHits().getHits()) {
						// get the JSON data per field
						Map<String, Object> json = hit.getSourceAsMap();
						String title = (String) json.get(BuildWikiIndexBulk.FieldNames.TITLE.name());
						String url = (String) json.get(BuildWikiIndexBulk.FieldNames.URL.name());
						String abstractText = (String) json.get(BuildWikiIndexBulk.FieldNames.ABSTRACT.name());
						Object rankObject = json.get(BuildWikiIndexBulk.FieldNames.RANK.name());

						// print the details of the doc (title, url, abstract) to standard out
						StringBuilder sb = new StringBuilder();
						sb.append(title).append("\t").append(url).append("\t").append(abstractText == null ? "" : abstractText);
						if (showScore) {
							sb.append("\t_score=").append(hit.getScore());
						}
						if (showRank) {
							sb.append("\t_rank=").append(rankObject == null ? "0.0" : rankObject.toString());
						}
						System.out.println(sb.toString());
					}
				} catch (Exception e) {
					System.err.println("Error with query '" + line + "'");
					e.printStackTrace();
				}
			}
		}
	}
}
