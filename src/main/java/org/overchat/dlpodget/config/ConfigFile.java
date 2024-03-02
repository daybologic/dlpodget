package org.overchat.dlpodget.config;

import java.io.File;
import java.io.IOException;
import java.util.Map;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.ini4j.Ini;

public class ConfigFile {
	private static final Logger logger = LogManager.getLogger(ConfigFile.class);
	private static final String FILENAME = "dlpodget.rc";

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
}
