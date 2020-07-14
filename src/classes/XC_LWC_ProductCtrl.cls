/**
 * @FileName: XC_LWC_ProductCtrl
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       7/2/2020         Created
 *-----------------------------------------------------------  
 */
public with sharing class XC_LWC_ProductCtrl {

    @AuraEnabled(Cacheable=true)
    public static List<XC_LWC_ProductCtrlHelper.DisplayableProduct> getSpotlightProducts() {
        return XC_LWC_ProductCtrlHelper.getSpotlightProducts();
    }

    @AuraEnabled(Cacheable=true)
    public static ConnectApi.ProductDetail getProduct(
            String communityId,
            String productId,
            String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = resolveCommunityIdToWebstoreId(communityId);

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods
        return ConnectApi.CommerceCatalog.getProduct(
                webstoreId,
                productId,
                effectiveAccountID,
                null,
                false,
                null,
                false,
                true,
                false
        );

    }

    @AuraEnabled(Cacheable=true)
    public static Boolean checkProductIsInStock(String productId) {
        return true;
    }

    @AuraEnabled
    public static ConnectApi.CartItem addToCart(
            String communityId,
            String productId,
            String quantity,
            String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = resolveCommunityIdToWebstoreId(communityId);

        ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
        cartInput.productId = productId;
        cartInput.quantity = quantity;
        cartInput.type = ConnectApi.CartItemType.PRODUCT;

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
        return ConnectApi.CommerceCart.addItemToCart(webstoreId, effectiveAccountId, 'active', cartInput);

    }


    @AuraEnabled(Cacheable=true)
    public static ConnectApi.ProductPrice getProductPrice(String communityId, String productId, String effectiveAccountId){

        // Lookup the webstore ID associated with the community
        String webstoreId = resolveCommunityIdToWebstoreId(communityId);

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods
        return ConnectApi.CommerceStorePricing.getProductPrice(webstoreId, productId, effectiveAccountId);
    }

    private static String resolveCommunityIdToWebstoreId(String communityId) {
        return [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId LIMIT 1].WebStoreId;
    }
}