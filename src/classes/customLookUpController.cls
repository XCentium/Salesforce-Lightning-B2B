public class customLookUpController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String fieldName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';

        List < sObject > returnList = new List < sObject > ();

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        // String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
		String sQuery =  'select id, ' + fieldName + ' from ' +ObjectName + ' where ' + fieldName + ' LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }

	@AuraEnabled
	public static sObject getMySingleObject(String objectName, String fieldName, String recordId) {
		String sQuery =  'select Id, ' + fieldName + ' from ' +ObjectName + ' where id =\'' + recordId + '\' limit 1';
		System.debug('sQuery : ' + sQuery);
        sObject returnValue = Database.query(sQuery);
		return returnValue;
	}
}