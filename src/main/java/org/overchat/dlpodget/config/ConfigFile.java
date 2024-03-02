package org.overchat.dlpodget.config;

import java.io.File;
import java.io.IOException;
import java.util.Map;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.ini4j.Ini;

import java.util.stream.Collectors; 
import java.util.stream.Stream; 
import java.util.*; 

public class ConfigFile {
	private final static String FILENAME = "dlpodget.rc";

	private static final Logger logger = LogManager.getLogger(ConfigFile.class);

	private File file;
	private Ini ini;

	public ConfigFile() {
		file = new File(FILENAME);
		try {
			ini = new Ini(file);
		}
		catch (IOException e) {
			logger.error(String.format("Can't open '%s'", FILENAME), e);
		}
	}

	/*public Map<String, Map<String, String>> parse() throws IOException {
		return ini.entrySet().stream().collect(toMap(Map.Entry::getKey, Map.Entry::getValue));
	}*/
}
