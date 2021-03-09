public class EinsteinMockNextBestAction {
	@AuraEnabled
    public static List<Contact> getRecommendationsbyContact(String recordId) {
        List<Contact> obj = new List<Contact>();
        obj = [SELECT RecommendationTitle1__c,RecommendationTitle2__c ,RecommendationDetails1__c,RecommendationDetails2__c FROM CONTACT WHERE Id = :recordId];  
        return obj;   
    }
    
    @AuraEnabled
    public static List<Case> getRecommendationsbyCase(String recordId) {
        List<Case> obj = new List<Case>();
        obj = [SELECT RecommendationTitle1__c,RecommendationTitle2__c,RecommendationDetails1__c,RecommendationDetails2__c FROM Case WHERE Id = :recordId];  
        return obj;   
    }
}