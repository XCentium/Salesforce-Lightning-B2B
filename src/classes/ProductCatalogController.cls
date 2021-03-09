public with sharing class ProductCatalogController {

    @AuraEnabled
	public static List<Product2> getProducts() {
	    // Check if we can view fields on Product
        Map<String,Schema.SObjectField> fieldDescribeTokens =
                Schema.SObjectType.Product2.fields.getMap();
        String[] fieldsToCheck = new String[] {'Id','Name','Family', 'VF_Image__c',
                'Default_Price__c','Inventory__c','Description'};
        for(String field : fieldsToCheck) {
            if( ! fieldDescribeTokens.get(field).getDescribe().isAccessible()) {
                throw new System.NoAccessException(); return null;
            }
        }
	    // LETS GO!
        return [SELECT Id, Name, Family, Default_Price__c,
                Inventory__c,Description,VF_Image__c
            FROM Product2
            WHERE Family != null
            ORDER BY Family ASC, Name ASC NULLS FIRST];
	}
    
    @AuraEnabled
    public static string createCatalogOrder(String accountId, List<Catalog_Line_Item__c> items) {
        // Check if we can view fields on Orders
        Map<String,Schema.SObjectField> fieldDescribeTokens =
                Schema.SObjectType.Catalog_Order__c.fields.getMap();
        String[] fieldsToCheck = new String[]{'Id','Name'};
        for(String field : fieldsToCheck) {
            if( ! fieldDescribeTokens.get(field).getDescribe().isAccessible()) {
                throw new System.NoAccessException(); return null;
            }
        }
        // Check if we can create fields on Orders
        fieldDescribeTokens =
                Schema.SObjectType.Catalog_Order__c.fields.getMap();
        fieldsToCheck = new String[]{'Account__c','Status__c'};
        for(String field : fieldsToCheck) {
            if( ! fieldDescribeTokens.get(field).getDescribe().isCreateable()) {
                throw new System.NoAccessException(); return null;
            }
        }
        // Check if we can create fields on LineItems
        fieldDescribeTokens =
                Schema.SObjectType.Catalog_Line_Item__c.fields.getMap();
        fieldsToCheck = new String[]{'Product__c','Quantity__c','Catalog_Order__c'};
        for(String field : fieldsToCheck) {
            if( ! fieldDescribeTokens.get(field).getDescribe().isCreateable()) {
                throw new System.NoAccessException(); return null;
            }
        }
        // LETS GO!
        Catalog_Order__c newOrder = new Catalog_Order__c();
        newOrder.Account__c = accountId;
        newOrder.Status__c = 'Submitted';

        insert newOrder;
        List<Catalog_Line_Item__c> lineItems =
                new List<Catalog_Line_Item__c>();
        for (Catalog_Line_Item__c lineItem : items) {
            lineItem.Catalog_Order__c = newOrder.Id;
            lineItems.add(lineItem);
        }
        insert lineItems;
        return [SELECT Name FROM Catalog_Order__c WHERE Id =: newOrder.Id].Name;
    }
    
    @AuraEnabled
    public static List<Account> getAccounts() {
        // Check if we can view fields on Account
        Map<String,Schema.SObjectField> fieldDescribeTokens =
                Schema.SObjectType.Account.fields.getMap();
        String[] fieldsToCheck = new String[]{'Id','Name'};
        for(String field : fieldsToCheck) {
            if( ! fieldDescribeTokens.get(field).getDescribe().isAccessible()) {
                throw new System.NoAccessException(); return null;
            }
        }
        // LETS GO
        return [SELECT Id, Name from Account];
    }
}