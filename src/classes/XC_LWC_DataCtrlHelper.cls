/**
 * @FileName: XC_LWC_DataCtrlHelper
 * @Description: Helper methods for the LWC data controller
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/18/2020       Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_LWC_DataCtrlHelper {

    public static List<XC_LWC_MenuWrapper.MenuItem> getMenuItems(String menuName) {
        XC_LWC_MenuWrapper menuWrapper = new XC_LWC_MenuWrapper(menuName);
        return menuWrapper.menuItems;
    }

    public static List<ApexClass> getActiveApexClasses() {
        return [SELECT Id, Name FROM ApexClass WHERE Status = 'Active'];
    }
}