/**
 * Created by brandon.rogers on 3/29/19.
 */

global with sharing class ckz_CategoryService extends ccrz.ccServiceCategory {

    global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData) {
        ccrz.ccLog.log('ckz_CategoryService', 'getFieldsMap');

        inputData = super.getFieldsMap(inputData);
        String objectFields = (String) inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',Top_Category__c,Top_Category_Name__c';

        return new Map<String, Object>{
                ccrz.ccService.OBJECTFIELDS => objectFields
        };
    }
}