/*
 * @FileName: XC_LWC_SobjectSearchCtrl
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/17/2020         Created
 *-----------------------------------------------------------  
 */
public with sharing class XC_LWC_SobjectSearchCtrl {

    @AuraEnabled
    public static String executeSearch(String criteriaJSON) {
        try {
            return XC_LWC_SobjectSearchCtrlHelper.executeSearch(criteriaJSON);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}