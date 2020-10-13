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
public inherited sharing class XC_Util_Query {

    public static String currentWebStoreId {get {
        if (String.isBlank(currentWebStoreId)) {
            Id networkId = Network.getNetworkId();

            if (String.isNotBlank(networkId)) {
                return [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :Network.getNetworkId() LIMIT 1].WebStoreId;
            }
            else if (Test.isRunningTest()) {
                return [SELECT Id FROM WebStore LIMIT 1].Id;
            }
            else {
                return [SELECT Id FROM WebStore WHERE Name = 'Albatross Golf' LIMIT 1].Id;
            }
        }

        return currentWebStoreId;
    } set;}

    public static User currentUser {get {
        if (currentUser == null) {
            currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        }

        return currentUser;
    } set;}

    public static ProductCategory productVariantCategory{get {
        if (productVariantCategory == null) {
            productVariantCategory = [SELECT Id FROM ProductCategory WHERE Name = :XC_Util_Constants.PRODUCT_VARIANTS_CATEGORY];
        }

        return productVariantCategory;
    } set;}
}