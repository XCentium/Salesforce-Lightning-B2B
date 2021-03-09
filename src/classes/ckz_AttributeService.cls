/**
 * Created by brandon.rogers on 4/29/20.
 */

global with sharing class ckz_AttributeService extends ccrz.ccServiceAttribute {

    global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData) {

        ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_AttributeService', 'inside getFieldsMap');

        inputData = super.getFieldsMap(inputData);

        String objectFields = (String) inputData.get(ccrz.ccService.OBJECTFIELDS);

        objectFields += ',useImageSwitcher__c';

        ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_AttributeService', 'objectFields: ' + objectFields);

        return new Map<String, Object>{
                ccrz.ccService.OBJECTFIELDS => objectFields
        };
    }

}