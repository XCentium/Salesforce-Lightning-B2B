global class SCCGlobalLogger {
    global static void log(String logMessage) {
		System.debug(System.LoggingLevel.INFO, 'SCCGlobalLogger: ' + logMessage);
    }
}