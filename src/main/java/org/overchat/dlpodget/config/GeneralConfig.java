package org.overchat.dlpodget.config;

/**
  * General configuration.
  * This may be global and it can be overridden per-feed.
  */
class GeneralConfig {
	boolean enable = false;
	String notify = "";
	int retries = 0;
	int rSleep = 0;
	boolean rSleepVary = true; // if 'r' is at the end of "rsleep"
	int maxTries = 0;
	int timeout = 30;
	boolean check = true;
	boolean download = true;
	Boolean attach;
	Codec codec = Codec.DEFAULT;
}
