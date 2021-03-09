/**
 * Created by brandon.rogers on 3/29/19.
 */

global with sharing class ckz_Hero_PromotionService extends ccrz.ccServicePromotion {

    global virtual override Map<String, Object> getFieldsMap(Map<String, Object> inputData) {
        inputData = super.getFieldsMap(inputData);
        String objectFields = (String) inputData.get(ccrz.ccService.OBJECTFIELDS);
        objectFields += ',Hero_Button_1_Category__c,Hero_Button_1_Description__c,Hero_Button_1_Product__c,Hero_Button_1_SKU__c,Hero_Button_1_Type__c,Hero_Button_1_URI__c,Hero_Button_1_Target__c,Hero_Button_2_Category__c,Hero_Button_2_Description__c,Hero_Button_2_Product__c,Hero_Button_2_SKU__c,Hero_Button_2_Type__c,Hero_Button_2_URI__c,Hero_Button_2_Target__c,Hero_Category_Related__c,Hero_Layout__c,Hero_Nav_Icon__c,Hero_Nav_Label__c,Hero_Product_Related__c,Hero_Text__c,Hero_Title__c,Hero_Video_Type__c,ccrz__Graphic_Type__c,Hero_Video_URI__c,Hero_Text_Position__c';

        return new Map<String, Object>{
                ccrz.ccService.OBJECTFIELDS => objectFields
        };
    }
}