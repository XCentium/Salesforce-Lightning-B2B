/**
 * Created by msobczak on 2/4/2019.
 */

public with sharing class ckz_PIM_ProductPricingController {

    @AuraEnabled
    public static List<Map<String, String>> fetchPriceListOptions(List<String> selectedStorefronts) {

        List<Map<String, String>> priceListOptions = new List<Map<String, String>>();

        List<ccrz__E_PriceList__c> priceLists = [SELECT Id, Name
        FROM ccrz__E_PriceList__c
        WHERE ccrz__Enabled__c = TRUE
        AND ccrz__Storefront__c IN :selectedStorefronts
        ORDER BY Name];

        for(ccrz__E_PriceList__c priceList : priceLists) {
            priceListOptions.add(new Map<String, String>{'value' => priceList.Id, 'label' => priceList.Name});
        }

        return priceListOptions;

    }

}