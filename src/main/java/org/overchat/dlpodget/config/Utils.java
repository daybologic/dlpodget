package org.overchat.dlpodget.config;

class Utils {
	static boolean makeBoolean(String option) {
		if (option.equals("true")) {
			return true;
		} else if (option.equals("false")) {
			return false;
		} else if (option.equals("1")) {
			return true;
		} else if (option.equals("0")) {
			return false;
		}

		return false;
	}
}
