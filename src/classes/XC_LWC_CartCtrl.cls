/**
 * @FileName: XC_LWC_CartCtrl
 * @Description: Cart controller methods
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/15/2020         Created
 *-----------------------------------------------------------  
 */
public with sharing class XC_LWC_CartCtrl {

    @AuraEnabled
    public static ConnectApi.CartItem addItemToCart(String productId, String quantity, String effectiveAccountId) {
        return XC_LWC_CartCtrlHelper.addItemToCart(productId, quantity, effectiveAccountId);
    }

    @AuraEnabled
    public static List<ConnectApi.BatchResult> addItemsToCart(Map<String,String> items, String effectiveAccountId) {
        return XC_LWC_CartCtrlHelper.addItemsToCart(items, effectiveAccountId);
    }

    @AuraEnabled
    public static List<ConnectApi.BatchResult> fillCartFromCSV(String csvContents, String effectiveAccountId) {
        System.debug(csvContents);
        return XC_LWC_CartCtrlHelper.fillCartFromCSV(csvContents, effectiveAccountId);
    }
}