package net.doepner.sample;

/**
 * Runs our Main.main method with Maven test classpath,
 * for manual testing, listening to real JMS messages.
 */
public class MainTester {

    private MainTester() {
        // should have no instances
    }

    public static void main(String... args) {
        Main.main();
    }
}
