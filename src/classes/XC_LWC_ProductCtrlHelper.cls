/**
 * @FileName: XC_LWC_ProductCtrlHelper
 * @Description: Helper methods for product controller
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       7/2/2020         Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_LWC_ProductCtrlHelper {

    public static XC_LWC_ProductWrappers.ProductDetails getProduct(String productId, String effectiveAccountId) {
        return new XC_LWC_ProductWrappers.ProductDetails(productId, effectiveAccountId);
    }

    public static XC_LWC_ProductWrappers.ProductDetails getProductImage(String recordId, String effectiveAccountId) {
        String objectType = XC_Util_Apex.getSObjectTypeById((Id) recordId);
        String productId;

        switch on objectType {
            when 'Product' {
                productId = recordId;
            }
            when 'OrderItem' {
                productId = [SELECT Id, Product2Id FROM OrderItem WHERE Id = :recordId].Product2Id;
            }
            when else {
                return null;
            }
        }

        return new XC_LWC_ProductWrappers.ProductDetails(productId, effectiveAccountId);
    }

    public static List<XC_LWC_ProductWrappers.SpotlightProduct> getSpotlightProducts(String effectiveAccountId, String locationKey) {
        List<Product2> products = [
                SELECT Id
                FROM Product2
                WHERE Spotlight_Location_Key__c = :locationKey
                LIMIT 3
        ];

        List<XC_LWC_ProductWrappers.SpotlightProduct> displayableProducts = new List<XC_LWC_ProductWrappers.SpotlightProduct>();

        for (Product2 p : products) {
            ConnectApi.ProductDetail productDetail = ConnectApi.CommerceCatalog.getProduct(
                    XC_Util_Query.currentWebStoreId,
                    p.Id,
                    effectiveAccountId,
                    null,
                    false,
                    null,
                    false,
                    true,
                    false
            );

            ConnectApi.ProductPrice productPrice = ConnectApi.CommerceStorePricing.getProductPrice(
                    XC_Util_Query.currentWebStoreId,
                    p.Id,
                    effectiveAccountId
            );

            displayableProducts.add(new XC_LWC_ProductWrappers.SpotlightProduct(p.Id, productDetail, productPrice));
        }

        return displayableProducts;
    }

    public static XC_LWC_ProductWrappers.ProductAttributes getProductAttributes(String productId){
        List<Product2> products = [
                SELECT Id,
                        (SELECT Id, Attribute__r.Attribute__c, Attribute__r.Value__c
                        FROM Product_Attributes__r)
                FROM Product2
                WHERE Parent_Product__c = :productId
        ];

        return new XC_LWC_ProductWrappers.ProductAttributes(products);
    }

    public static XC_LWC_ProductWrappers.ProductAggregates getProductAggregates(String productId) {
        Product2 parentProduct = [
                SELECT Id, Aggregate_Column__c, Aggregate_Row__c, Aggregate_Column_Sequence__c, Aggregate_Row_Sequence__c,
                    (SELECT Id FROM Child_Products__r)
                FROM Product2
                WHERE Id =:productId
        ];

        if (parentProduct.Child_Products__r.isEmpty()) return null;

        Set<Id> childProductIds = new Set<Id>();

        for (Product2 p : parentProduct.Child_Products__r) {
            childProductIds.add(p.Id);
        }

        List<Product_Attribute__c> attributes = [
                SELECT Id, Product__c, Attribute__r.Attribute__c, Attribute__r.Value__c
                FROM Product_Attribute__c
                WHERE Product__c IN :childProductIds
                AND (Attribute__r.Attribute__c = :parentProduct.Aggregate_Column__c
                    OR Attribute__r.Attribute__c = :parentProduct.Aggregate_Row__c)
                ORDER BY Attribute__r.Value__c ASC
        ];

        XC_LWC_ProductWrappers.ProductAggregates pv = new XC_LWC_ProductWrappers.ProductAggregates(parentProduct, attributes);

        return pv;
    }
}