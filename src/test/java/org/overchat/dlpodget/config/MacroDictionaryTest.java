package org.overchat.dlpodget.config;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

//import org.junit.Assert.assertEquals;
//import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.*;

public class MacroDictionaryTest {

	private MacroDictionary sut;

	@BeforeEach
	public void setUp() {
		sut = new MacroDictionary();
	}

	@Test
	public void testNothingToDo() {
		final String input = "Y5XBx9ThW1wSCXLYidaFiULbABnsaCuz";
		assertEquals(input, sut.resolve(input), "Nothing changed");
	}
}
