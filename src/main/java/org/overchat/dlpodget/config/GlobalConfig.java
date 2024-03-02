package org.overchat.dlpodget.config;

/**
  * Global configuration. This is not feed-specific and cannot be overridden
  * per-feed.  The config section is called [main].
  */
class GlobalConfig {
	boolean debug = false;
	boolean noop = false;
	int maxChildren = 0;
	int childDelay = 0;
	boolean popCon = false;
}
