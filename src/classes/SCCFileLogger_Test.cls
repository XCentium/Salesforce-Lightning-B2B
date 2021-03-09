@IsTest
public class SCCFileLogger_Test {

	@IsTest
	static void test_method_one() {
		SCC_LogLevels__c slogLevel = new SCC_LogLevels__c();
		slogLevel.Loglevel__c = 'SYSDEBUG';
		slogLevel.Name = 'All';
		Database.insert(slogLevel);
		SCCFileLogger logger = SCCFileLogger.getInstance();
		logger.info('SCCFileLogger_Test.test_method_one', 'Testing SCCFileLogger - info');
		logger.error('SCCFileLogger_Test.test_method_one', 'Testing SCCFileLogger - error');
		logger.fatal('SCCFileLogger_Test.test_method_one', 'Testing SCCFileLogger - fatal');
		logger.trace('SCCFileLogger_Test.test_method_one', 'Testing SCCFileLogger - trace');
		logger.debug('SCCFileLogger_Test.test_method_one', 'Testing SCCFileLogger - debug');
	}

	@IsTest
	static void test_method_two() {
		SCC_LogLevels__c slogLevel = new SCC_LogLevels__c();
		slogLevel.Loglevel__c = 'DEBUG';
		slogLevel.Name = 'All';
		Database.insert(slogLevel);
		SCCFileLogger logger = SCCFileLogger.getInstance();
		logger.info('SCCFileLogger_Test.test_method_one', 'Testing SCCFileLogger - info');
		logger.error('SCCFileLogger_Test.test_method_one', 'Testing SCCFileLogger - error');
		logger.fatal('SCCFileLogger_Test.test_method_one', 'Testing SCCFileLogger - fatal');
		logger.trace('SCCFileLogger_Test.test_method_one', 'Testing SCCFileLogger - trace');
		logger.debug('SCCFileLogger_Test.test_method_one', 'Testing SCCFileLogger - debug');
		logger.flush();
	}

	@IsTest
	static void test_method_three() {
		SCC_LogLevels__c slogLevel = new SCC_LogLevels__c();
		slogLevel.Loglevel__c = 'DEBUG';
		slogLevel.Name = 'All';
		Database.insert(slogLevel);
		SCCFileLogger logger = SCCFileLogger.getInstance();
		logger.info('', 'Testing SCCFileLogger - info');
		logger.error('', 'Testing SCCFileLogger - error');
		logger.fatal('', 'Testing SCCFileLogger - fatal');
		logger.trace('', 'Testing SCCFileLogger - trace');
		logger.debug('', 'Testing SCCFileLogger - debug');
		logger.flush();
	}

}