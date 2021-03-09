/*
    * Created by Jesse Chase
        * jchase@salesforce.com
            * 10/23/2018.
*/
public class MLMDownline {
    /** Get Contact Downline **/
    @AuraEnabled
    public static List<Contact> GetContactDownline(String ContactID) {
        return [SELECT Id, Name, FirstName, Lastname,ReportsToId, Total_of_Activities__c, Phone ,Direct_Recruits__c ,Total_of_Guests__c, Total_Items_Sold__c,Tier__c,Profile_Image_URL__c,Total_Order_Amount__c FROM Contact WHERE ReportsToId =:ContactID];
    }
    
    /** Get Contact Downline Count **/
    @AuraEnabled
    public static Integer GetContactDownlineCount(String ContactID) {
        return [SELECT count() FROM Contact WHERE ReportsToId =:ContactID];
    }
}