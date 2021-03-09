public class ConversationToolkitNBAController {
    
    @AuraEnabled
    public static List<Conversation_Helper__c> getConversationHelperList(){
        return [SELECT ID,Value__c, Recommended_Action__c, Agent__c, Customer__c FROM Conversation_Helper__c WHERE Active__c = true];        
    }
    
}