package cl.uchile.pmd;

import java.lang.reflect.Method;

import org.apache.logging.log4j.core.config.Configurator;
import org.apache.logging.log4j.core.config.builder.api.AppenderComponentBuilder;
import org.apache.logging.log4j.core.config.builder.api.ConfigurationBuilder;
import org.apache.logging.log4j.core.config.builder.api.ConfigurationBuilderFactory;
import org.apache.logging.log4j.core.config.builder.impl.BuiltConfiguration;

/**
 * Class for running one of many possible command line tasks
 * in the CLI package.
 * 
 * YOU CAN IGNORE THIS CLASS :)
 * 
 * @author Aidan Hogan
 */
public class Main {
	
	private static final String PREFIX = "cl.uchile.pmd.";
	private static final String USAGE = "usage: "+Main.class.getName();

	/**
	 * Main method
	 * @param args Command line args, first of which is the utility to run
	 */
	public static void main(String[] args) {
		// set the logger configuration to avoid annoying messages :)
		ConfigurationBuilder<BuiltConfiguration> builder = ConfigurationBuilderFactory.newConfigurationBuilder();
		AppenderComponentBuilder console = builder.newAppender("stderr", "Console");
		builder.add(console);
		Configurator.initialize(builder.build());
		
		// now read the command line arguments; the first should be the class to call
		try {
			if (args.length < 1) {
				StringBuffer sb = new StringBuffer();
				sb.append("missing <utility> arg where <utility> one of");
				sb.append("\n\t"+BuildWikiIndexBulk.class.getSimpleName()+": Index text in Elasticsearch");
				sb.append("\n\t"+SearchWikiIndex.class.getSimpleName()+": Search over the Elasticsearch index");
				
				usage(sb.toString());
			}

			Class<? extends Object> cls = Class.forName(PREFIX + args[0]);

			Method mainMethod = cls.getMethod("main", new Class[] { String[].class });

			String[] mainArgs = new String[args.length - 1];
			System.arraycopy(args, 1, mainArgs, 0, mainArgs.length);

			long time = System.currentTimeMillis();
			
			mainMethod.invoke(null, new Object[] { mainArgs });

			long time1 = System.currentTimeMillis();

			System.err.println("time elapsed " + (time1-time) + " ms");
		} catch (Throwable e) {
			e.printStackTrace();
			usage(e.toString());
		}
	}

	private static void usage(String msg) {
		System.err.println(USAGE);
		System.err.println(msg);
		System.exit(-1);
	}
}
