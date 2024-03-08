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
		this.macroDictionary.depth = 0; // FIXME: Crude hack
		return this.macroDictionary.resolve(input);
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

		// DEBUGGING
//		logger.trace("Resolving politics: " + macroDictionary.resolve("politics"));
//		logger.trace("Resolving radio: " + macroDictionary.resolve("radio"));
//		logger.trace("Resolving acooke_lfabushjr: " + macroDictionary.resolve("acooke_lfabushjr"));
//		logger.trace("Resolving comedy: " + macroDictionary.resolve("comedy"));
		final String __s = "$RADIO/sarc";
		logger.trace(String.format("Resolving %s: \'%s\'", __s, macroDictionary.resolve(__s)));
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
