/**
 * @FileName: XC_LWC_DataCtrl
 * @Description: Controller methods for returning data to lighting web components
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/18/2020       Created
 *-----------------------------------------------------------  
 */
public with sharing class XC_LWC_DataCtrl {

    @AuraEnabled
    public static List<XC_LWC_MenuWrapper.MenuItem> getMenuItems(String menuName) {
        return XC_LWC_DataCtrlHelper.getMenuItems(menuName);
    }

    @AuraEnabled(Cacheable=true)
    public static List<ApexClass> getActiveApexClasses() {
        return XC_LWC_DataCtrlHelper.getActiveApexClasses();
    }
}