@isTest
private class ConversationToolkitNBATestClass {
    static testMethod void ConversationToolkitNBATestClass() {
        
        Conversation_Helper__c chInput = new Conversation_Helper__c();
        chInput.Value__c = 'TestValue';
        chInput.Active__c = true;
        insert chInput;

        List<Conversation_Helper__c> conversationList = ConversationToolkitNBAController.getConversationHelperList();
        System.assertNotEquals(0, conversationList.size());
        //Test Comment
    }
}