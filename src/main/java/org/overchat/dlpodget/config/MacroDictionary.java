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
		macros = new HashMap<>(30);
	}

	void set(String key, String value) {
		key = key.toUpperCase();

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

	String get(final String key) {
		return macros.get(key.toUpperCase());
	}

	public int depth = 0; // TODO: Crude; requires improvement
	String resolve(String value) {
		int offset = 0;
		depth++;
		do {
			logger.trace(String.format("value \'%s\', offset %d before indexOf", value, offset));
			offset = value.indexOf("$", offset);
			logger.trace(String.format("value \'%s\', offset %d after indexOf", value, offset));
			if (offset > -1) {
				offset++;
				value = value.substring(offset);
				logger.trace("Running matcher on \'" + value + "\' (ABC must be at start or we fail)");
				Matcher matcher = pattern.matcher(value);
				int matchesDebug = 0;
				while (matcher.find()) {
					logger.trace("MATCH FOUND");
					matchesDebug++;
					String group1 = matcher.group(1);
					logger.trace(String.format("group1 is \'%s\'", group1));
					String subst = get(group1);
					logger.trace(String.format("Subst is \'%s\'", subst));
					logger.trace(String.format("Old value is \'%s\'", value));
					value = value.replace(group1, subst);
					logger.trace(String.format("New value is \'%s\'", value));
				}

				logger.trace(String.format("matches count %d", matchesDebug));
			}
			if (depth < 15) value = resolve(value); // TODO: Crude; requires improvement
		} while (offset > -1);

		return value;
	}
}
