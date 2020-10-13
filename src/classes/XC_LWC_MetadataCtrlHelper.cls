/**
 * @FileName: XC_LWC_MetadataCtrlHelper
 * @Description: Helper methods for the LWC data controller
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/18/2020       Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_LWC_MetadataCtrlHelper {

    public static List<ApexClass> getActiveApexClasses() {
        return [SELECT Id, Name FROM ApexClass WHERE Status = 'Active' ORDER BY Name ASC];
    }
}