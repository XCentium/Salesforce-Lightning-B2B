/**
 * Created by brandon.rogers on 2019-12-11.
 */

global with sharing class ckz_ProductService extends ccrz.ccServiceProduct {

    global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData) {

        ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckzPOCServiceProduct', 'inside getFieldsMap');

        inputData = super.getFieldsMap(inputData);

        String objectFields = (String) inputData.get(ccrz.ccService.OBJECTFIELDS);

        objectFields += ',Min_Qty__c,Max_Qty__c,Min_Spend__c';
        objectFields += ',Checkout_Unavailable__c';
        objectFields += ',ckz_isAssortment__c';

        ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckzPOCServiceProduct', 'objectFields: ' + objectFields);

        return new Map<String, Object>{
                ccrz.ccService.OBJECTFIELDS => objectFields
        };
    }

    global virtual override Map<String, Object> getSubQueryMap(Map<String, Object> inputData) {

        ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckzPOCServiceProduct', 'inside getSubQueryMap');

        Map<String, Object> localizedSubQMap = super.getSubQueryMap(inputData);

        ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckzPOCServiceProduct', 'localizedSubQMap: ' + localizedSubQMap);

        // INVENTORY ITEMS
        String origQuery = (String) localizedSubQMap.get('Product_Inventory_Items__r');
        if (origQuery != null) {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckzPOCServiceProduct', 'origQuery: ' + origQuery);
            String newQuery = '(SELECT Id, Name, ccrz__AvailabilityMessageRT__c, ccrz__InventoryLocationCode__c, ccrz__ProductItem__c, ccrz__QtyAvailable__c, ccrz__Status__c, Warehouse_Location__c, Expected_Ship_Date__c FROM Product_Inventory_Items__r)';
            localizedSubQMap.put('Product_Inventory_Items__r', newQuery);
        }

        // PRODUCT MEDIA
        if (localizedSubQMap.containsKey('E_ProductMedias__r') == TRUE) {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ProductService.getSubQueryMap()', 'E_ProductMedias__r FOUND');
            localizedSubQMap.put('E_ProductMedias__r', '(SELECT Id, Name, RecordTypeId, Product__c, AltMessage__c, Enabled__c, EndDate__c, FilePath__c, Locale__c, MediaType__c, ProductDescription__c, ProductMediaId__c, ProductMediaSource__c, Sequence__c, StartDate__c, StaticResourceName__c, URI__c, CC_Attribute__r.Name FROM E_ProductMedias__r WHERE (Locale__c = :fullLocale OR Locale__c = :langLocale OR Locale__c = :defaultLocale OR Locale__c = null) AND (StartDate__c <=TODAY AND EndDate__c >= TODAY) ORDER BY Sequence__c ASC) ');
        } else {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ProductService.getSubQueryMap()', 'E_ProductMedias__r NOT FOUND');
        }

        return localizedSubQMap;
    }

}