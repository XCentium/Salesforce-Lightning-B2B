/**
 * @FileName: XC_Util_Query
 * @Description: Class to lazy load variables that require queries
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       7/1/2020         Created
 *-----------------------------------------------------------  
 */
public with sharing class XC_Util_Query {

    public static String currentWebstoreId {get {
        if (String.isBlank(currentWebstoreId)) {
            return [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :Network.getNetworkId() LIMIT 1].WebStoreId;
        }

        return currentWebstoreId;
    } set;}
}