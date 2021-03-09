/**
 * Created by msobczak on 2/4/2019.
 */

public with sharing class ckz_PIM_ProductDetailController {

    @AuraEnabled
    public static List<Map<String, String>> fetchStorefrontOptions() {

        System.debug('inside fetchStorefrontOptions()');

        Set<String> storefronts = new Set<String>();
        List<Map<String, String>> storefrontList = new List<Map<String, String>>();

        try {
            System.debug('getting configs');
            List<AggregateResult> configs = [SELECT ccrz__Storefront__c FROM ccrz__E_Configuration__c GROUP BY ccrz__Storefront__c];

            System.debug('looping through results');
            for (AggregateResult ag : configs) {
                String storefrontName = (String)ag.get('ccrz__Storefront__c');
                if(storefrontName != 'Global') {
                    storefronts.add(storefrontName);
                }
            }

            //storefrontList.addAll(storefronts);
            for(String storefront : storefronts) {
                storefrontList.add(new Map<String, String>{'label' => storefront, 'value' => storefront});
            }

            System.debug('storefrontList.size = ' + storefrontList.size());
        } catch (Exception ex) {

            System.debug('error message: ' + ex.getMessage());
            System.debug('line number: ' + ex.getLineNumber());

        }

        System.debug('exit fetchStorefrontOptions()');

        return storefrontList;
    }

}