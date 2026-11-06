package cl.uchile.pmd;

import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.UnknownHostException;

import org.elasticsearch.client.transport.TransportClient;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.common.transport.TransportAddress;
import org.elasticsearch.transport.client.PreBuiltTransportClient;

/**
 * Stores constants associated with the cluster.
 * It would be better to read them from a config file in practice.
 */
public class ElasticsearchCluster {
	public static String CLUSTERNAME = "es-pmd";
	public static String HOSTNAME = "cm";
	public static int PORT = 9300;

	public static TransportClient getTransportClient() throws UnknownHostException {
		Settings settings = Settings.builder()
				.put("cluster.name", CLUSTERNAME).build();

		@SuppressWarnings("resource") //will be closed by higher level client
		PreBuiltTransportClient pclient = new PreBuiltTransportClient(settings);
		return pclient.addTransportAddress(new TransportAddress(new InetSocketAddress(InetAddress.getByName(HOSTNAME), PORT)));
	}
}
