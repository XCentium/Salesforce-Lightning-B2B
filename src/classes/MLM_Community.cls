public class MLM_Community {
    /** Get Community To-Do **/
    @AuraEnabled
    public static List<Contact> todo() {
        id userId = UserInfo.getUserId();
        User u = [select id, contactId from User where id = : userId];
        id getContactId = u.contactId;
        return [SELECT Id, Name, Email ,Phone ,MailingAddress ,FirstName, Lastname,ReportsToId, Total_of_Activities__c ,Direct_Recruits__c ,Total_of_Guests__c, Total_Items_Sold__c,Tier__c,Profile_Image_URL__c,Total_Order_Amount__c FROM Contact WHERE ReportsToId =:getContactId];
    }
}