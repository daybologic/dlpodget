package org.overchat.dlpodget.config;

import org.ini4j.Ini;

/**
  * Global configuration. This is not feed-specific and cannot be overridden
  * per-feed.  The config section is called [main].
  */
class GlobalConfig {
	GeneralConfig general;

	boolean debug = false;
	boolean noop = false;
	int maxChildren = 0;
	int childDelay = 0;
	boolean popCon = false;

	GlobalConfig(Ini ini, Ini.Section section) {
		general = new GeneralConfig(ini, ini.get("main"));

		debug = Utils.makeBoolean(section.get("debug"));
		noop = Utils.makeBoolean(section.get("noop"));
		popCon = Utils.makeBoolean(section.get("popcon"));
	}
}
