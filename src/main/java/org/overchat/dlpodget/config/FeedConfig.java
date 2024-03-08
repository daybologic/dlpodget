package org.overchat.dlpodget.config;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.ini4j.Ini;

/**
  * Feed configuration. This is feed-specific and may not appear
  * in the [main] section.
  */
class FeedConfig {
	private static final Logger logger = LogManager.getLogger(FeedConfig.class);

	GeneralConfig general;

	String rssUrl = "";
	String localpath = "";

	FeedConfig(ConfigFile configFile, Ini ini, Ini.Section section) {
		general = new GeneralConfig(ini, ini.get("main"));

		rssUrl = section.get("rss");
		logger.trace("rss: " + rssUrl);

		localpath = section.get("localpath");
		logger.trace("localpath (raw): " + localpath);

		localpath = configFile.resolveMacro(localpath);
		logger.trace("localpath (cooked): " + localpath);
	}
}
