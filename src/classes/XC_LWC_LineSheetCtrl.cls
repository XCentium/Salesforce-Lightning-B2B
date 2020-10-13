/*
 * @FileName: XC_LWC_LineSheetCtrl
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/21/2020         Created
 *-----------------------------------------------------------
 */
public with sharing class XC_LWC_LineSheetCtrl {

    @AuraEnabled
    public static String getTemplateOptions() {
        return XC_LWC_LineSheetCtrlHelper.getTemplateOptions();
    }

    @AuraEnabled
    public static String getLineSheets() {
        return XC_LWC_LineSheetCtrlHelper.getLineSheets();
    }

    @AuraEnabled
    public static String getContactLineSheets() {
        return XC_LWC_LineSheetCtrlHelper.getContactLineSheets();
    }

    @AuraEnabled
    public static String getLineSheet(String lineSheetId) {
        return XC_LWC_LineSheetCtrlHelper.getLineSheet(lineSheetId);
    }

    @AuraEnabled
    public static String getItem(String productId, String contactId) {
        return XC_LWC_LineSheetCtrlHelper.getItem(productId, contactId);
    }

    @AuraEnabled
    public static String saveLineSheet(String wrapperJSON) {
        return XC_LWC_LineSheetCtrlHelper.saveLineSheet(wrapperJSON);
    }

    @AuraEnabled
    public static void deleteLineSheet(String lineSheetId) {
        XC_LWC_LineSheetCtrlHelper.deleteLineSheet(lineSheetId);
    }
}