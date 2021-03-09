/**
 * Created by brandon.rogers on 9/6/18.
 */

public with sharing class ckz_util_Common {

    public static List<ccrz__E_PriceGroupAccount__c> fetchPriceGroupAccounts(String accountId) {
        ccrz.ccLog.log('ckz_util_Common:fetchPriceGroupAccounts');
        System.debug('ckz_util_Common:fetchPriceGroupAccounts');
        Date dateVal = Date.today();

        String storeName = ccrz.cc_CallContext.storefront;

        ccrz.ccLog.log('ckz_util_Common:fetchPriceGroupAccounts', 'storeName: ' + storeName);  System.debug('storeName: ' + storeName);
        ccrz.ccLog.log('ckz_util_Common:fetchPriceGroupAccounts', 'accountId: ' + accountId);  System.debug('accountId: ' + accountId);
        ccrz.ccLog.log('ckz_util_Common:fetchPriceGroupAccounts', 'dateVal: ' + dateVal);  System.debug('dateVal: ' + dateVal);

        return [
                SELECT
                        ID,
                        ccrz__PriceGroup__c,
                        ccrz__PriceGroup__r.ccrz__GroupName__c
                FROM
                        ccrz__E_PriceGroupAccount__c
                WHERE
                ccrz__Account__c = :accountId
                AND
                ccrz__Enabled__c = true
                AND
                ccrz__PriceGroup__r.ccrz__Enabled__c = true
                AND
                (ccrz__EffectiveStart__c <= :dateVal OR ccrz__EffectiveStart__c = NULL)
                AND
                (ccrz__EffectiveEnd__c > :dateVal OR ccrz__EffectiveEnd__c = NULL)
                AND
                ccrz__Storefront__c = :storeName
                AND
                ccrz__PriceGroup__r.ccrz__EffectiveStart__c <= :dateVal
                AND
                ccrz__PriceGroup__r.ccrz__EffectiveEnd__c > :dateVal
                LIMIT 2000
        ];
    }

}