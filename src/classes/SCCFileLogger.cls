public class SCCFileLogger {

   	// private static variable referencing the class
    private static SCCFileLogger instance = null;


	//Loglevel String Integer mapping
	private static Map<String, Integer> logLevelMap = new Map<String, Integer>();
	private Integer intSetLogLevel = 0;
    private String text = '';
    private Document doc = null;
    private String logName = null;

	static
	{
		logLevelMap.put('OFF', 1);
		logLevelMap.put('FATAL', 2);
		logLevelMap.put('ERROR', 3);
		logLevelMap.put('INFO', 4);
		logLevelMap.put('TRACE', 5);
		logLevelMap.put('DEBUG', 6);
        logLevelMap.put('SYSDEBUG', 7);
	}

    	/**
    * @description Constructor: Create log main record
    * @param strLogName		Name of the log record
    * @param strLogType		Log type
	* @param strObjectName	Name of the object for which log is created
    * @param strObjectId	Id of the logged object
    */
	public SCCFileLogger ()
	{
		String strSetLogLevelName = 'OFF';

		//Check current loglevel setting
		List<SCC_LogLevels__c> SCCLogLevelsList = SCC_LogLevels__c.getall().values();

		for(SCC_LogLevels__c currLogLevel :SCCLogLevelsList)
		{
            //store object settings loglevel value
            strSetLogLevelName = currLogLevel.Loglevel__c;
            break;
		}

		//Convert loglevel name to integer
		intSetLogLevel = logLevelMap.get(strSetLogLevelName);
		//No loglevel found, assuming ERROR
		if(intSetLogLevel < 1)
		{
			intSetLogLevel = 1;
		}
	}

    //  Static method that returns the instance
    public static SCCFileLogger getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if(instance == null) instance = new SCCFileLogger();
        return instance;
    }

    public void fatal(String strLogName, String message) {
        if(intSetLogLevel >= 2 && intSetLogLevel < 7){
            //set log name
            if(String.isEmpty(strLogName)){
                logName = 'SCCDefault';
            }else{
                logName = strLogName;
            }
            text += logName + ' - FATAL: ' + message + '\n';
        }
        if(intSetLogLevel == 7){
            System.debug(strLogName+' : '+message);
        }
    }

    public void error(String strLogName, String message) {
        if(intSetLogLevel >= 3 && intSetLogLevel < 7){
            //set log name
            if(String.isEmpty(strLogName)){
                logName = 'SCCDefault';
            }else{
                logName = strLogName;
            }
        	text += logName + ' - ERROR: ' + message + '\n';
        }
        if(intSetLogLevel == 7){
            System.debug(strLogName+' : '+message);
        }
    }

    public void info(String strLogName, String message) {
        if(intSetLogLevel >= 4 && intSetLogLevel < 7){
            //set log name
            if(String.isEmpty(strLogName)){
                logName = 'SCCDefault';
            }else{
                logName = strLogName;
            }
        	text += logName + ' - INFO:  ' + message + '\n';
        }
        if(intSetLogLevel == 7){
            System.debug(strLogName+' : '+message);
        }
    }

    public void trace(String strLogName, String message) {
        if(intSetLogLevel >= 5 && intSetLogLevel < 7){
            //set log name
            if(String.isEmpty(strLogName)){
                logName = 'SCCDefault';
            }else{
                logName = strLogName;
            }
        	text += logName + ' - TRACE: ' + message + '\n';
        }
        if(intSetLogLevel == 7){
            System.debug(strLogName+' : '+message);
        }
    }

    public void debug(String strLogName, String message) {
        if(intSetLogLevel >= 6 && intSetLogLevel < 7){
            //set log name
            if(String.isEmpty(strLogName)){
                logName = 'SCCDefault';
            }else{
                logName = strLogName;
            }
            text += logName + ' - DEBUG: ' + message + '\n';
        }
        if(intSetLogLevel == 7){
            System.debug(strLogName+' : '+message);
        }
    }

    public void flush() {
        if(intSetLogLevel > 1 && intSetLogLevel < 7){
            //Get log document by name
            String documentName = 'SCCLog-'+Date.today();
            Document[] docs = [SELECT Body FROM Document WHERE Name = :documentName AND FolderId = :UserInfo.getUserId()];

            // Append if exists or create
            doc = docs.size() == 1
                ? docs[0]
                : new Document(
                    FolderId = UserInfo.getUserId(), // "My Personal Documents" folder
                    Name = documentName,
                    Body = Blob.valueOf(''),
                    ContentType = 'text/plain',
                    Type = 'txt'
                );
            doc.Body = Blob.valueOf(doc.Body.toString() + text);
            try {
            	upsert doc;
            } catch (DmlException dmlE) {
                System.debug('SCCFileLogger:flush: failure encountered when attempting to upsert document: ' + dmlE.getMessage());
            }

            text = '';
        }
    }
}