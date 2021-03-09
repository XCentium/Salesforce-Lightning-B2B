public class CustomSearchController {
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord, String ObjectName, String fieldName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
		String sQuery;
        List < sObject > returnList = new List < sObject > ();

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5
        // String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        if(String.isBlank(ObjectName)){
            sQuery =  'select Id, Name from Contact where Name LIKE: searchKey order by createdDate DESC limit 5';
        }else{
            sQuery =  'select Id, Name from ' + ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        }
        
        
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