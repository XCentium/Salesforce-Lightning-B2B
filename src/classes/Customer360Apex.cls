public with sharing class Customer360Apex {
    @AuraEnabled
    public static List<Order> getRecentOrder(String accountId){
        Account currentPerson = [SELECT Id , Name  
                                 FROM Account 
                                 WHERE RecordTypeId = '0121U000000qE9vQAE' AND Id =: accountId]; 
        system.debug(currentPerson);
        system.debug([SELECT Name, TotalAmount, EffectiveDate, Order_Image__c, BillToContactId FROM Order 
                      WHERE BillToContact.Name =: currentPerson.Name ORDER BY EffectiveDate DESC LIMIT 4]);        
        return [SELECT Name, TotalAmount, EffectiveDate, Order_Image__c, BillToContactId FROM Order 
                WHERE BillToContact.Name =: currentPerson.Name ORDER BY EffectiveDate DESC LIMIT 4];
    }
    @AuraEnabled
    public static List<Order> getRecentOrderFromCase(String caseId){
        Case currentCase = [SELECT Id, AccountId, ContactId FROM Case WHERE Id =: caseId];
        system.debug(currentCase);
        return [SELECT Name, TotalAmount, EffectiveDate, Order_Image__c, BillToContactId FROM Order 
                WHERE BillToContactId =: currentCase.ContactId ORDER BY EffectiveDate DESC LIMIT 4];
    }
    @AuraEnabled
    public static List<Order> getRecentOrderFromContact(String contactId){
        Contact currentContact = [SELECT Id, AccountId FROM Contact WHERE Id =: contactId];
        return [SELECT Name, TotalAmount, EffectiveDate, Order_Image__c, BillToContactId FROM Order 
                WHERE BillToContactId =: currentContact.Id ORDER BY EffectiveDate DESC LIMIT 4];
    }
    
    @AuraEnabled
    public static Contact getContactFromContact(String contactId){            
        return [SELECT Profile_Metric_1__c, Profile_Metric_2__c , Profile_Metric_3__c , Profile_Metric_4__c 
                FROM Contact WHERE Id =: contactId];
    }
    @AuraEnabled
    public static Contact getContactFromCase(String caseId){    
        Case currentCase = [SELECT ContactId FROM Case WHERE Id =: caseId];
        if(currentCase != null){
            return [SELECT Profile_Metric_1__c, Profile_Metric_2__c , Profile_Metric_3__c , Profile_Metric_4__c 
                    FROM Contact WHERE Id =: currentCase.ContactId];
        } else{
            return null;
        }
    }
    @AuraEnabled
    public static Account getContactFromPerson(String personId){    
        return [SELECT Profile_Metric_1__pc, Profile_Metric_2__pc , Profile_Metric_3__pc , Profile_Metric_4__pc 
                FROM Account WHERE RecordTypeId = '0121U000000qE9vQAE' AND Id =: personId];
    }
    @AuraEnabled
    public static String getLabel(String fieldAPIName){
        Map<String, Schema.SObjectField> M;
        M = Schema.SObjectType.Contact.fields.getMap();
        Schema.SObjectField field = M.get(fieldAPIName);
        DescribeFieldResult describe = field.getDescribe();
        String label = describe.getLabel();
        system.debug(label);
        return label;
    }
    @AuraEnabled
    public static Most_Viewed_Interest__c[] getMostViewedFromContact(String contactId){
        return [SELECT Title__c, Interest__c, Image__c FROM Most_Viewed_Interest__c WHERE Contact__c =: contactId ORDER BY CreatedDate DESC LIMIT 4];
    }
    @AuraEnabled
    public static Most_Viewed_Interest__c[] getMostViewedFromCase(String caseId){
        Case currentCase = [SELECT Id, ContactId FROM Case WHERE Id =: caseId];
        system.debug(currentCase);
        return [SELECT Title__c, Interest__c, Image__c  FROM Most_Viewed_Interest__c WHERE Contact__c =: currentCase.ContactId ORDER BY CreatedDate DESC LIMIT 4];
    }
    @AuraEnabled
    public static Most_Viewed_Interest__c[] getMostViewedFromPerson(String accountId){
        Account currentPerson = [SELECT Id , Name  
                                 FROM Account 
                                 WHERE RecordTypeId = '0121U000000qE9vQAE' AND Id =: accountId]; 
        system.debug(currentPerson);
        system.debug([SELECT Title__c, Interest__c, Image__c  FROM Most_Viewed_Interest__c WHERE Contact__r.Name =: currentPerson.Name ORDER BY CreatedDate DESC LIMIT 4]);
        return [SELECT Title__c, Interest__c, Image__c  FROM Most_Viewed_Interest__c WHERE Contact__r.Name =: currentPerson.Name ORDER BY CreatedDate DESC LIMIT 4];
    }
    @AuraEnabled
    public static Wishlist_Item__c[] getWishlistFromContact(String contactId){
        return [SELECT Title__c, Date_Added__c, Price__c, Image__c  FROM Wishlist_Item__c WHERE Contact__c =: contactId ORDER BY CreatedDate DESC LIMIT 4];
    }
    @AuraEnabled
    public static Wishlist_Item__c[] getWishlistFromCase(String caseId){
        Case currentCase = [SELECT Id, ContactId FROM Case WHERE Id =: caseId];
        system.debug(currentCase);
        return [SELECT Title__c, Date_Added__c, Price__c, Image__c  FROM Wishlist_Item__c WHERE Contact__c =: currentCase.ContactId ORDER BY CreatedDate DESC LIMIT 4];
    }
    @AuraEnabled
    public static Wishlist_Item__c[] getWishlistFromPerson(String accountId){
        Account currentPerson = [SELECT Id , Name  
                                 FROM Account 
                                 WHERE RecordTypeId = '0121U000000qE9vQAE' AND Id =: accountId]; 
        system.debug(currentPerson);
        system.debug([SELECT Title__c, Date_Added__c, Price__c, Image__c  FROM Wishlist_Item__c WHERE Contact__r.Name =: currentPerson.Name ORDER BY CreatedDate DESC LIMIT 4]);
        return [SELECT Title__c, Date_Added__c, Price__c, Image__c  FROM Wishlist_Item__c WHERE Contact__r.Name =: currentPerson.Name ORDER BY CreatedDate DESC LIMIT 4];
    }
    @AuraEnabled
    public static In_Basket_Item__c[] getBasketItemFromContact(String contactId){
        return [SELECT Title__c, Price__c, Image__c  FROM In_Basket_Item__c WHERE Contact__c =: contactId ORDER BY CreatedDate DESC LIMIT 4];
    }   
    @AuraEnabled
    public static In_Basket_Item__c[] getBasketItemFromCase(String caseId){
        Case currentCase = [SELECT Id, ContactId FROM Case WHERE Id =: caseId];
        system.debug(currentCase);
        return [SELECT Title__c, Price__c, Image__c  FROM In_Basket_Item__c WHERE Contact__c =: currentCase.ContactId ORDER BY CreatedDate DESC LIMIT 4];
    } 
    @AuraEnabled
    public static In_Basket_Item__c[] getBasketItemFromPerson(String accountId){        
        Account currentPerson = [SELECT Id , Name  
                                 FROM Account 
                                 WHERE RecordTypeId = '0121U000000qE9vQAE' AND Id =: accountId]; 
        system.debug(currentPerson);
        system.debug([SELECT Title__c, Price__c, Image__c  FROM In_Basket_Item__c WHERE Contact__r.Name =: currentPerson.Name ORDER BY CreatedDate DESC LIMIT 4]);
        return [SELECT Title__c, Price__c, Image__c  FROM In_Basket_Item__c WHERE Contact__r.Name =: currentPerson.Name ORDER BY CreatedDate DESC LIMIT 4];
    } 
}