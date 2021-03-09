global with sharing class ckzPOCServiceAccount extends ccrz.ccServiceAccount {
    global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData) {
        inputData = super.getFieldsMap(inputData);

        String objectFields = (String) inputData.get(ccrz.ccService.OBJECTFIELDS);

        objectFields += ',ckz_B2B_Credit_Limit__c';

        // Reward Points fields
        objectFields += ',ckz_B2B_Reward_Points_Balance__c,ckz_B2B_Reward_Points_Cost_Multiplier__c,ckz_B2B_Reward_Points_Earned_Multiplier__c,ckz_B2B_Reward_Points_Enabled__c' ;

        // 2020-04-20  msobczak - Price List Upgrade field
        objectFields += ',B2B_Total_Order_Amount__c';

        return new Map <String, Object>{
                ccrz.ccService.OBJECTFIELDS => objectFields
        };
    }
}