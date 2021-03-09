public class FindObjectType {
	@AuraEnabled
    public static String getObject(Id recid) {     
        Schema.SObjectType sobjectType = recid.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        String s = String.valueOf(sobjectName);
        return s;
    }
}