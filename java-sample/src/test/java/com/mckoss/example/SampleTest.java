package com.mckoss.example;

import static org.junit.Assert.assertNotNull;

import org.junit.Test;
import org.junit.Ignore;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

@RunWith(JUnit4.class)
public class SampleTest {
    @Test
    public void canCallMain() {
        Sample s = new Sample();
        assertNotNull(s);
        s.main("one", "two", "three");
    }
}
