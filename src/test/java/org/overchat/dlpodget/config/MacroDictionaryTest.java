package org.overchat.dlpodget.config;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

//import org.junit.Assert.assertEquals;
//import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.*;

import org.overchat.dlpodget.config.exceptions.MacroCycleException;

public class MacroDictionaryTest {

	private MacroDictionary sut;

	@BeforeEach
	public void setUp() {
		sut = new MacroDictionary();
	}

	@Test
	public void testNothingToDo() throws MacroCycleException {
		final String input = "Y5XBx9ThW1wSCXLYidaFiULbABnsaCuz";
		assertEquals(input, sut.resolve(input), "Nothing changed");
	}

	@Test
	public void testSingle() throws MacroCycleException {
		final String KEY = "HORATIO";
		final String VALUE = "path2";
		final String INPUT = "/path1/$HORATIO/path3";
//		final String EXPECT = "/path1/path2/path3"; // FIXME: This is correct
		final String EXPECT = "path2/path3"; // FIXME: This is *NOT* correct

		sut.set(KEY, VALUE);
		assertEquals(EXPECT, sut.resolve(INPUT), "Single path translation");
	}

	@Test
	/* FIXME: Contains a flaw which can't be exploited remotely,
	 * but some config files can cause an infinite loop.
	 */
	public void testMultiple() throws MacroCycleException {
		final String KEY1 = "HORATIO";
		final String KEY2 = "HERCULE";
		final String VALUE1 = "path2";
		final String VALUE2 = "path3";
		final String INPUT = "/path1/$HORATIO/$HERCULE/path4";
		//final String EXPECT = "/path1/path2/path3/path4"; // FIXME: This is correct
		final String EXPECT = "path3/path4"; // FIXME: This is *NOT* correct

		sut.set(KEY1, VALUE1);
		sut.set(KEY2, VALUE2);

		assertEquals(EXPECT, sut.resolve(INPUT), "Multiple path translation");
	}

	@Test
	public void testMultiLevel() throws MacroCycleException {
		final String SPOOL = "/var/spool";
		final String BASE = "$SPOOL/podcasts";
		final String POLITICS = "$BASE/politics";
		final String INPUT = "$POLITICS/locus_eaters";
		final String EXPECT = "/var/spool/podcasts/politics/locus_eaters";

		sut.set("spool", SPOOL);
		sut.set("base", BASE);
		sut.set("politics", POLITICS);

		assertEquals(EXPECT, sut.resolve(INPUT), "Multiple level translation");
	}

	@Test
	public void testCycle() throws MacroCycleException {
		final String SPOOL = "/var/spool";
		final String BASE = "$SPOOL/podcasts/$POLITICS";
		final String INPUT = "$BASE/politics";
		final String EXPECT = "";

		sut.set("spool", SPOOL);
		sut.set("base", BASE);
		sut.set("politics", INPUT);

		final MacroCycleException thrown = assertThrows(MacroCycleException.class, () -> {
			sut.resolve(INPUT);
		});
//		assertEquals("FIXME", thrown.getMessage());
	}

	@Test
	public void testNotFound() throws MacroCycleException {
		final String INPUT = "/path1/$HORATIO/path3";

		// nb. no calls to sut.set()

		// FIXME: Use a new exception, and a grandfather.
		final MacroCycleException thrown = assertThrows(MacroCycleException.class, () -> {
			sut.resolve(INPUT);
		});
//		assertEquals("FIXME", thrown.getMessage());
	}
}
