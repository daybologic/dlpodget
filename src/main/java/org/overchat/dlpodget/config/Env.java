package org.overchat.dlpodget.config;

import java.util.Map;

public class Env {
	static final private Map<String, String> env = System.getenv();

	static String get(final String key) {
		if (env.containsKey(key)) return env.get(key);
		throw new RuntimeException(String.format("The environment variable \'%s\' must be set", key));
	}
}
