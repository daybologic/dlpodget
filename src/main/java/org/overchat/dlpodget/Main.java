package org.overchat.dlpodget;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.overchat.dlpodget.config.ConfigFile;

public class Main {
	private static final Logger logger = LogManager.getLogger(Main.class);
	private static ConfigFile config;

	public static void main(String args[]) {
		logger.info("Dlpodget started (Java version)");
		config = new ConfigFile();
		System.exit(0);
	}
}
