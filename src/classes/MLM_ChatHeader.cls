public class MLM_ChatHeader {
    @AuraEnabled 
	public static List<Contact> getContact(Id recId) {
        String caseDetails;
        caseDetails = [Select ContactEmail FROM Case WHERE Id = :recId LIMIT 1].ContactEmail; 
        
        List<Contact> contact = new LIST<Contact>();  
        contact=[Select Name,FirstName,LastName,Id,Email, Phone , Profile_Image_URL__c    FROM Contact WHERE Email = :caseDetails LIMIT 1]; 
        return contact; 
    }
}