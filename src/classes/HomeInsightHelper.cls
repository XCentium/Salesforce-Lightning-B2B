public class HomeInsightHelper {
	@AuraEnabled
    public static String getRecordId(String recordName, String objectType){
        String query = 'Select Id From ' + objectType + ' Where Name = \'' + recordName + '\'';
        return Database.query(query).Id;
    }
}