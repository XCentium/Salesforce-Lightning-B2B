public with sharing class b2b_util_WarrantyRenewal {

    private static final List<String> statusList = new List<String>{'Released', 'Not Orderable'};

    public static String getWarrantyProduct(String recordId){

        System.debug('recordId: ' + recordId);

        String sku = null;

        String warrantySku = null;

        // Get the current asset and related order items

        List<Asset> assetList = [SELECT Id, Name, CC_Order_Item__r.ccrz__Product__c FROM Asset WHERE Id = :recordId];

        System.debug('assetList: ' + assetList);

        if(assetList.isEmpty() || assetList.size() <= 0) {
            return warrantySku;
        }

        Asset asset = assetList.get(0);

        Id productId = asset.CC_Order_Item__r.ccrz__Product__c;

        System.debug('productId: ' + productId);

        if(productId == null) {
            return warrantySku;
        }

        List<ccrz__E_Product__c> objList = [SELECT
                Id,
                Name,
                ccrz__SKU__c
        FROM ccrz__E_Product__c
        WHERE Id = :productId
        AND ccrz__ProductStatus__c IN :statusList];

        if(objList.isEmpty() == false && objList.size() > 0) {
            ccrz__E_Product__c obj = objList.get(0);

            sku = obj.ccrz__SKU__c;
        }

        System.debug('sku: ' + sku);

        if(sku == null) {
            return warrantySku;
        }

        String searchSku = sku + '-WTY';

        System.debug('searchSku: ' + searchSku);

        objList = [SELECT
                Id,
                Name,
                ccrz__SKU__c
        FROM ccrz__E_Product__c
        WHERE ccrz__SKU__c = :searchSku
        //and ccrz__Storefront__c = :storefront
        AND ccrz__ProductStatus__c IN :statusList];

        if(objList.isEmpty() == false && objList.size() > 0) {
            ccrz__E_Product__c obj = objList.get(0);

            warrantySku = obj.ccrz__SKU__c;
        }

        System.debug('warrantySku: ' + warrantySku);

        return warrantySku;

    }

    public static String fetchCommunityUrl(String community) {
        Network myCommunity = [SELECT Id FROM Network WHERE Name = :community];
        ConnectApi.Community comm = ConnectApi.Communities.getCommunity(myCommunity.Id);
        String baseURL = comm.siteUrl;
        return baseURL;
    }

}