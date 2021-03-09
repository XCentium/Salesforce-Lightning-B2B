global with sharing class ckzPOCServiceContact extends ccrz.ccServiceContact {

    global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData) {
        inputData = super.getFieldsMap(inputData);

        String objectFields = (String) inputData.get(ccrz.ccService.OBJECTFIELDS);

        objectFields += ',ckz_Budget_Administrator__c,ckz_Budget_Limit__c,ckz_Budget_Can_Order__c,ckz_Budget_Requires_Approval__c' ;

        return new Map <String, Object>{
                ccrz.ccService.OBJECTFIELDS => objectFields
        };
    }

}