/**
 * @FileName: XC_LWC_ProductCtrl
 * @Description: Product controller methods
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       7/2/2020         Created
 *-----------------------------------------------------------  
 */
public with sharing class XC_LWC_ProductCtrl {

    @AuraEnabled(Cacheable=true)
    public static XC_LWC_ProductWrappers.ProductDetails getProduct(String productId, String effectiveAccountId) {
        return XC_LWC_ProductCtrlHelper.getProduct(productId, effectiveAccountId);
    }

    @AuraEnabled(Cacheable=true)
    public static XC_LWC_ProductWrappers.ProductDetails getProductImage(String recordId, String effectiveAccountId) {
        return XC_LWC_ProductCtrlHelper.getProductImage(recordId, effectiveAccountId);
    }

    @AuraEnabled(Cacheable=true)
    public static List<XC_LWC_ProductWrappers.SpotlightProduct> getSpotlightProducts(String effectiveAccountId, String locationKey) {
        return XC_LWC_ProductCtrlHelper.getSpotlightProducts(effectiveAccountId, locationKey);
    }

    @AuraEnabled(Cacheable=true)
    public static ConnectApi.ProductPrice getProductPrice(String productId, String effectiveAccountId){
        return ConnectApi.CommerceStorePricing.getProductPrice(XC_Util_Query.currentWebStoreId, productId, effectiveAccountId);
    }

    @AuraEnabled(Cacheable=true)
    public static XC_LWC_ProductWrappers.ProductAttributes getProductAttributes(String productId){
        return XC_LWC_ProductCtrlHelper.getProductAttributes(productId);
    }

    @AuraEnabled(Cacheable=true)
    public static XC_LWC_ProductWrappers.ProductAggregates getProductAggregates(String productId){
        return XC_LWC_ProductCtrlHelper.getProductAggregates(productId);
    }
}