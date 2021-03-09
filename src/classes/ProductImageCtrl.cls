public class ProductImageCtrl {
	@AuraEnabled
    public static Id getCCProduct(String ProdId) {
        return [SELECT Id FROM ccrz__E_Product__c WHERE Product__c = :ProdId].Id;
    }
}