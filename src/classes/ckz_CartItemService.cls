/**
 * Created by brandon.rogers on 2/11/20.
 */

global with sharing class ckz_CartItemService extends ccrz.ccServiceCartItem {

    global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData) {
        ccrz.ccLog.log('ckz_CategoryService', 'getFieldsMap');

        inputData = super.getFieldsMap(inputData);
        String objectFields = (String) inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',Original_Subtotal__c';

        return new Map<String, Object>{
                ccrz.ccService.OBJECTFIELDS => objectFields
        };
    }

}