package org.mdp.utils;

public class MemStats {
	private static final Runtime RM = Runtime.getRuntime();
	
	public static final String getMemStats(){
		return "Memory (bytes) "+getUsedMemory()+"/"+getMaxMemory()+
				 " ["+String.format("%.3f",(getUsedMemory()*100d)/+getMaxMemory())+"%]";
	}
	
	public static final long getUsedMemory(){
		//System.gc();
		return RM.totalMemory() - RM.freeMemory();
	}
	
	public static final long getMaxMemory(){
		return RM.maxMemory();
	}
}
