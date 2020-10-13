/**
 * @FileName: XC_LWC_DataCtrl
 * @Description: Methods for retrieving and parsing data for lightning components
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       8/18/2020         Created
 *-----------------------------------------------------------
 */
public with sharing class XC_LWC_DataCtrl {

    @AuraEnabled
    public static XC_LWC_DataWrappers.OrderPadOptions getOrderPadOptions() {
        return XC_LWC_DataCtrlHelper.getOrderPadOptions();
    }

    @AuraEnabled
    public static XC_LWC_DataWrappers.OrderPadOptions refreshOrderPadOptions(String activeFilter, String category, String brand) {
        return XC_LWC_DataCtrlHelper.getOrderPadOptions(activeFilter, category, brand);
    }
}