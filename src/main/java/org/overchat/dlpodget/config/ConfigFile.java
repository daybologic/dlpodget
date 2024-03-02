package org.overchat.dlpodget.config;

import java.io.File;
import java.io.IOException;
import java.util.Set;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.ini4j.Ini;

public class ConfigFile {
	private static final Logger logger = LogManager.getLogger(ConfigFile.class);
	private static final String FILENAME = "dlpodget.rc";

	private File file;
	private Ini ini;
	private GlobalConfig main;

	public ConfigFile() {
		file = new File(FILENAME);
		try {
			ini = new Ini(file);
		}
		catch (IOException e) {
			logger.error(String.format("Can't open '%s'", FILENAME), e);
			System.exit(1);
		}

		parse();
	}

	private void parse() {
		parseMain();
		parseFeeds();
	}

	private void parseMain() {
		Ini.Section section = ini.get("main");
		logger.trace(section);
		main = new GlobalConfig(ini, section);
	}

	private void parseFeeds() {
		Set<String> sectionNames = ini.keySet();
		logger.trace(sectionNames);
		for (String sectionName: sectionNames) {
			if (sectionName.equals("main")) continue;
			logger.trace(sectionName);
			new FeedConfig(ini, ini.get(sectionName)); // TODO
		}
	}
}
