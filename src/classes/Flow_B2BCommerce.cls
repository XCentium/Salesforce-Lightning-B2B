public class Flow_B2BCommerce {
	@AuraEnabled
    public static List<ccrz__E_Cart__c > getCCCart(String ContactId) {
        return [Select Id, ccrz__Contact__c ,ccrz__ActiveCart__c,Name ,Opportunity__c,ccrz__TotalAmount__c,ccrz__TotalDiscount__c From ccrz__E_Cart__c Where (ccrz__Contact__c = :ContactId) AND (ccrz__ActiveCart__c = true)];
    }
    /* Get Cart Items */
    @AuraEnabled
    public static List<ccrz__E_CartItem__c> getCartItems(String cartId) {
        return [Select Id,ccrz__Product__r.Name,ccrz__Product__r.Product__r.purl__c,ccrz__Price__c  From ccrz__E_CartItem__c Where ccrz__Cart__c  = :cartId];
    }
}