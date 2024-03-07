package org.overchat.dlpodget.config;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

class MacroDictionary {
	private static final Logger logger = LogManager.getLogger(MacroDictionary.class);
	private static Pattern pattern = Pattern.compile("^([A-Z]+)");
	private Map<String, String> macros;

	MacroDictionary() {
		macros = new HashMap<>(1);
	}

	void set(String key, final String value) {
		key = key.toUpperCase(); // all keys must be upper-case

		if (macros.containsKey(key)) {
			logger.warn(String.format(
				"Macro %s set again, value \'%s\' clobbers previous value \'%s\'",
				key, value, macros.get(key)
			));
		} else {
			logger.debug(String.format("Added macro %s -> \'%s\'", key, value));
		}

		macros.put(key, value);
	}

	String get(final String key) { // TODO: Need to make this work without the key, but just a long string of which the key is part
		return macros.get(key);
	}

	String resolve(String key) {
		key = key.toUpperCase(); // all keys must be upper-case

		if (get(key) != null) {
			String value = get(key);
			int offset;
			do {
				offset = value.indexOf("$", 0);
				if (offset > -1) {
					offset++;
					Matcher matcher = pattern.matcher(value.substring(offset));
					int matchesDebug = 0;
					while (matcher.find()) {
						//logger.trace("MATCH FOUND");
						matchesDebug++;
						// TODO: what if get() returns null?
						String group1 = matcher.group(1);
						//logger.trace(String.format("group1 is \'%s\'", group1));
						String subst = get(group1);
						//logger.trace(String.format("Subst is \'%s\'", subst));
						//logger.trace(String.format("Old value is \'%s\'", value));
						value = value.replace("$" + group1, subst);
						//logger.trace(String.format("New value is \'%s\'", value));
					}

					//logger.trace(String.format("matches count %d", matchesDebug));
				}
			} while (offset > -1);
			return value;
		}

		logger.warn(String.format("Attempt to resolve macro \'%s\', which does not exist", key));
		return "";
	}
}
