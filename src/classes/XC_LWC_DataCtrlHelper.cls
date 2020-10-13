/**
 * @FileName: XC_LWC_DataCtrlHelper
 * @Description: Helper methods for the data controller
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       8/18/2020         Created
 *-----------------------------------------------------------
 */
public inherited sharing class XC_LWC_DataCtrlHelper {

    public static XC_LWC_DataWrappers.OrderPadOptions getOrderPadOptions() {
        return new XC_LWC_DataWrappers.OrderPadOptions();
    }

    public static XC_LWC_DataWrappers.OrderPadOptions getOrderPadOptions(String activeFilter, String category, String brand) {
        return new XC_LWC_DataWrappers.OrderPadOptions(activeFilter, category, brand);
    }
}