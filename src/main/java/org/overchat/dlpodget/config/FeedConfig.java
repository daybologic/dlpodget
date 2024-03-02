package org.overchat.dlpodget.config;

/**
  * Feed configuration. This is feed-specific and may not appear
  * in the [main] section.
  */
class FeedConfig {
	GeneralConfig general;

	String rssUrl = "";
	String localpath = "";

	FeedConfig() {
		general = new GeneralConfig();
	}
}
