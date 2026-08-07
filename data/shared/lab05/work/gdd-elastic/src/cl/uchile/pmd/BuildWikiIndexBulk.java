package cl.uchile.pmd;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.rmi.AlreadyBoundException;
import java.util.HashMap;
import java.util.Map;
import java.util.zip.GZIPInputStream;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.elasticsearch.action.admin.indices.create.CreateIndexResponse;
import org.elasticsearch.action.bulk.BulkRequestBuilder;
import org.elasticsearch.client.transport.TransportClient;
import org.elasticsearch.common.xcontent.XContentType;

/**
 * Main method to index plain-text abstracts from Wikipedia using ElasticSearch.
 * 
 * @author Aidan, Alberto
 */
public class BuildWikiIndexBulk {

	public enum FieldNames {
		URL, TITLE, MODIFIED, ABSTRACT, RANK
	}
	public static int TICKS = 10000;

	public static int BATCH_SIZE = 250;
	
	public static String mappingJson = "{\n" +
		    "  \"settings\": {\n" +
		    "    \"number_of_shards\": 1,\n" +
		    "    \"number_of_replicas\": 0\n" +
		    "  },\n" +
		    "  \"mappings\": {\n" +
		    "    \"_doc\": {\n" +
		    "      \"properties\": {\n" +
		    "        \"URL\":      { \"type\": \"keyword\", \"store\": true },\n" +
		    "        \"TITLE\":    { \"type\": \"text\", \"analyzer\": \"spanish\", \"store\": true },\n" +
		    "        \"ABSTRACT\": { \"type\": \"text\", \"analyzer\": \"spanish\", \"store\": true },\n" +
		    "        \"MODIFIED\": { \"type\": \"long\" },\n" +
		    "        \"RANK\":     { \"type\": \"double\", \"store\": true }\n" +
		    "      }\n" +
		    "    }\n" +
		    "  }\n" +
		    "}";

	public static void main(String args[]) throws IOException, ClassNotFoundException, AlreadyBoundException,
	InstantiationException, IllegalAccessException {
		Option inO = new Option("i", "input file");
		inO.setArgs(1);
		inO.setRequired(true);

		Option ingzO = new Option("igz", "input file is GZipped");
		ingzO.setArgs(0);

		Option outO = new Option("o", "output elasticsearch index name");
		outO.setArgs(1);
		outO.setRequired(true);

		Option rankO = new Option("r", "input TSV file with PageRank values per URL");
		rankO.setArgs(1);

		Option helpO = new Option("h", "print help");

		Options options = new Options();
		options.addOption(inO);
		options.addOption(ingzO);
		options.addOption(outO);
		options.addOption(rankO);
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

		String indexName = cmd.getOptionValue("o");
		System.err.println("Indexing at  " + indexName);

		String in = cmd.getOptionValue(inO.getOpt());
		System.err.println("Opening input at  " + in);
		InputStream is = new FileInputStream(in);
		if (cmd.hasOption(ingzO.getOpt())) {
			is = new GZIPInputStream(is);
		}
		BufferedReader br = new BufferedReader(new InputStreamReader(is, "utf-8"));
		Map<String, Double> ranksByUrl = null;
		if (cmd.hasOption(rankO.getOpt())) {
			String ranksPath = cmd.getOptionValue(rankO.getOpt());
			System.err.println("Opening ranks at  " + ranksPath);
			ranksByUrl = loadRanksByUrl(ranksPath);
			System.err.println("... loaded " + ranksByUrl.size() + " rank values");
		}

		TransportClient client = ElasticsearchCluster.getTransportClient();
		
		CreateIndexResponse createIndexResponse = client.admin().indices()
			    .prepareCreate(indexName)
			    .setSource(mappingJson, XContentType.JSON)
			    .get();

		indexTitleAndAbstract(br, client, indexName, ranksByUrl);

		br.close();
		client.close();
	}

	public static Map<String, Double> loadRanksByUrl(String path) throws IOException {
		Map<String, Double> ranksByUrl = new HashMap<>();
		BufferedReader rankReader = new BufferedReader(new InputStreamReader(new FileInputStream(path), "utf-8"));
		try {
			String line = null;
			while ((line = rankReader.readLine()) != null) {
				line = line.trim();
				if (line.isEmpty()) {
					continue;
				}
				String[] tabs = line.split("\t");
				if (tabs.length < 2) {
					continue;
				}
				try {
					ranksByUrl.put(tabs[0], Double.parseDouble(tabs[1]));
				} catch (NumberFormatException e) {
					// ignore malformed rank values
				}
			}
		} finally {
			rankReader.close();
		}
		return ranksByUrl;
	}

	public static void indexTitleAndAbstract(BufferedReader input, TransportClient client, String indexName, Map<String, Double> ranksByUrl) throws IOException {
		String line = null;
		int read = 0;

		BulkRequestBuilder bulkJson = client.prepareBulk();
		// read each line from input (tab separated)
		// first element: URL
		// second element: title
		// third element: abstract (optional)
		while ((line = input.readLine()) != null) {
			read++;
			line = line.trim();
			if (!line.isEmpty()) {
				String[] tabs = line.split("\t");
				if (tabs.length >= 2) {
					// we store the JSON document as a map from
					// strings (keys) to objects (values)
					Map<String, Object> json = new HashMap<>();
					
					json.put(FieldNames.URL.name(), tabs[0]);
					json.put(FieldNames.TITLE.name(), tabs[1]);
					if (tabs.length > 2 && tabs[2] != null && !tabs[2].isEmpty()) {
						json.put(FieldNames.ABSTRACT.name(), tabs[2]);
					}
					double rankValue = 0d;
					if (ranksByUrl != null) {
						Double storedRank = ranksByUrl.get(tabs[0]);
						if (storedRank != null) {
							rankValue = storedRank.doubleValue();
						}
					}
					json.put(FieldNames.RANK.name(), rankValue);
					json.put(FieldNames.MODIFIED.name(), System.currentTimeMillis());


					// add to bulk request
					bulkJson.add(client.prepareIndex(indexName, "_doc").setSource(json, XContentType.JSON));

					// if we have read a multiple of batch size
					if(read % BATCH_SIZE == 0) {
						// send the request (i.e., get the unused response of the request)
						bulkJson.get();
						bulkJson = client.prepareBulk();
					}
				}
			}

			if (read % TICKS == 0) {
				System.err.println("... read " + read);
			}
		}

		// if we have something left in the batch to send ...
		if(bulkJson.numberOfActions() > 0) {
			// send the request (i.e., get the unused response of the request)
			bulkJson.get();
		}
	}
}
