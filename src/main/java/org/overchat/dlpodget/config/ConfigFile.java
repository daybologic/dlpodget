package org.overchat.dlpodget.config;

import java.io.File;
import java.io.IOException;
import java.util.Set;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.ini4j.Ini;

import org.overchat.dlpodget.config.exceptions.MacroCycleException;

public class ConfigFile {
	private static final Logger logger = LogManager.getLogger(ConfigFile.class);
	private static final String FILENAME = "dlpodget.rc";

	private File file;
	private Ini ini;
	private GlobalConfig main;
	private MacroDictionary macroDictionary;

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

	public String resolveMacro(final String input) {
		String resolved = "";

		try {
			resolved = this.macroDictionary.resolve(input);
		} catch (MacroCycleException e) {
			logger.error("Cannot resolve macro", e);
		}

		return resolved.isEmpty() ? input : resolved;
	}

	private void parse() {
		parseMain();
		parsePaths();
		parseFeeds();
	}

	private void parseMain() {
		Ini.Section section = ini.get("main");
		main = new GlobalConfig(ini, section);
	}

	private void parsePaths() {
		macroDictionary = new MacroDictionary();

		Ini.Section paths = ini.get("paths");

		String root = paths.get("root");
		logger.trace("root: " + root);
		macroDictionary.set("LOCALPFX", root);

		String home = Env.get("HOME");
		logger.trace("HOME: " + home);
		macroDictionary.set("HOME", home);

		String user = Env.get("USER");
		logger.trace("USER: " + user);
		macroDictionary.set("USER", user);

		Set<String> pathNames = paths.keySet();
		logger.trace(pathNames);
		for (String pathName: pathNames) {
			logger.trace("path: " + pathName);
			macroDictionary.set(pathName, paths.get(pathName));
		}

		try {
			// DEBUGGING
			logger.trace("Resolving politics: " + macroDictionary.resolve("politics"));
			logger.trace("Resolving radio: " + macroDictionary.resolve("radio"));
			logger.trace("Resolving acooke_lfabushjr: " + macroDictionary.resolve("acooke_lfabushjr"));
			logger.trace("Resolving comedy: " + macroDictionary.resolve("comedy"));
		}
		catch (MacroCycleException e) {
			logger.trace("the macro cycle exception piece (A): ", e);
		}

		// FIXME: Demonstrates a problem we need to debug
		/*final String __s = "blah/$LOCALPFX/$USER/$TECH/$RADIO/sarc";
		String __resolved = "";
		try {
			__resolved = macroDictionary.resolve(__s);
		}
		catch (MacroCycleException e) {
			logger.trace("the macro cycle exception piece (B): ", e);
		}
		logger.trace(String.format("Resolving %s: \'%s\'", __s, __resolved));*/
//		System.exit(0); // FIXME
	}

	private void parseFeeds() {
		Set<String> sectionNames = ini.keySet();
		logger.trace(sectionNames);
		for (String sectionName: sectionNames) {
			// Skip over reserved section names
			if (sectionName.equals("main")) continue;
			if (sectionName.equals("paths")) continue;

			logger.trace(sectionName);
			new FeedConfig(this, ini, ini.get(sectionName)); // TODO
		}
	}
}
