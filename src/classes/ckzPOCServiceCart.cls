global with sharing class ckzPOCServiceCart extends ccrz.ccServiceCart {

    global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData) {
        inputData = super.getFieldsMap(inputData);

        String objectFields = (String) inputData.get(ccrz.ccService.OBJECTFIELDS);

        objectFields += ',Custom_Message_Type__c,Custom_Message_Text__c' ;

        // User Budget Extension
        objectFields += ',Budget_Approval_Requested__c,Budget_Approved_for_Checkout__c,Budget_Override__c';

        // Credit Limit Extension
        objectFields += ',Credit_Override_Requested__c,Credit_Override_Approved_for_Checkout__c,Credit_Override__c' ;

        // Reward points
        objectFields += ',Reward_Points_Applied__c';

        return new Map <String, Object>{
                ccrz.ccService.OBJECTFIELDS => objectFields
        };
    }

}