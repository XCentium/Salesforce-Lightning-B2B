/**
 * @FileName: XC_LWC_CartCtrl
 * @Description: Cart controller methods
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/15/2020         Created
 *-----------------------------------------------------------  
 */
public without sharing class XC_LWC_CartCtrl {

    @AuraEnabled
    public static ConnectApi.CartItem addItemToCart(String productId, String quantity, String effectiveAccountId) {
        return XC_LWC_CartCtrlHelper.addItemToCart(productId, quantity, effectiveAccountId);
    }

    @AuraEnabled
    public static List<ConnectApi.BatchResult> addItemsToCart(Map<String,String> items, String effectiveAccountId) {
        return XC_LWC_CartCtrlHelper.addItemsToCart(items, effectiveAccountId);
    }


    /**
   * @description Demonstrates how to call ConnectApi.CommerceCart.getCartItems
   * @param  communityId The Id of the community from which the call originated
   * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
   * @param activeCartOrId ID of the cart, active, or current.
   * @param pageParam Specifies the page token to be used to view a page of information.
   * @param sortParam Sort order for items in a cart.
   * @return CartItemCollection A collection of cart items
   */
    @AuraEnabled
    public static ConnectApi.CartItemCollection getCartItems(
            String communityId,
            String effectiveAccountId,
            String activeCartOrId,
            String pageParam,
            String sortParam
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

        // Get the ConnectApi.CartItemSortOrder enum value from string.
        // For the list of possible values, see:
        // see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/connectAPI_enums.htm#cartItemSortOrderEnum
        ConnectApi.CartItemSortOrder resolvedSortParam = B2BUtils.resolveSortParam(
                sortParam
        );

        verifyQuantity(communityId, webstoreId, effectiveAccountId, activeCartOrId);

        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        return ConnectApi.CommerceCart.getCartItems(
                webstoreId,
                effectiveAccountId,
                activeCartOrId,
                pageParam,
                resolvedSortParam
        );
    }

    /**
     * @description Demonstrates how to call ConnectApi.CommerceCart.updateCartItem
     * @param  communityId The Id of the community from which the call originated
     * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
     * @param activeCartOrId ID of the cart, active, or current.
     * @param cartItemId ID of the cart item to be updated.
     * @return CartItem The updated cart item
     */
    @AuraEnabled
    public static ConnectApi.CartItem updateCartItem(
            String communityId,
            String effectiveAccountId,
            String activeCartOrId,
            String cartItemId,
            ConnectApi.CartItemInput cartItem
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        return ConnectApi.CommerceCart.updateCartItem(
                webstoreId,
                effectiveAccountId,
                activeCartOrId,
                cartItemId,
                cartItem
        );
    }

    public static void verifyQuantity(String communityId, String webstoreId, String effectiveAccountId, String activeCartOrId) {
        ConnectApi.CartItemCollection cartItems = ConnectApi.CommerceCart.getCartItems(
                webstoreId,
                effectiveAccountId,
                activeCartOrId
        );

        Set<Id> productIds = new Set<Id>();
        Map<Id,Decimal> quantityByProduct = new Map<Id,Decimal>{};


        for (ConnectApi.CartItemResult res : cartItems.cartItems) {
            Decimal quantity = Decimal.valueOf(res.cartItem.quantity);
            Id productId = res.cartItem.productDetails.productId;
            productIds.add(productId);
            quantityByProduct.put(productId, quantity);
        }

        List<Product2> products = [
                SELECT Id, Unit_Quantity__c,
                        (SELECT Id, Large_Product__c, Large_Product__r.Unit_Quantity__c
                        FROM Quantity_Variants__r
                        WHERE Large_Product__r.Unit_Quantity__c != NULL
                        ORDER BY Large_Product__r.Unit_Quantity__c DESC)
                FROM Product2
                WHERE Id IN :productIds
                AND Unit_Quantity__c != NULL
        ];

        Decimal quantity;

        Map<String,String> productsToAdd = new Map<String,String>();
        Map<String,String> productsToUpdate = new Map<String,String>();
        Set<Id> productsToRemove = new Set<Id>();

        for (Product2 p : products) {
            quantity = quantityByProduct.get(p.Id) * p.Unit_Quantity__c;

            for (Quantity_Variant__c qv : p.Quantity_Variants__r) {
                Decimal qvQuantity = qv.Large_Product__r.Unit_Quantity__c;

                if (quantity < qvQuantity) continue;

                Decimal newQuantity = (quantity / qvQuantity).round(System.RoundingMode.DOWN);

                if (productIds.contains(qv.Large_Product__c)) {
                    Decimal updateQuantity = quantityByProduct.get(qv.Large_Product__c) + newQuantity;
                    productsToUpdate.put(qv.Large_Product__c, String.valueOf(updateQuantity));
                }
                else {
                    productsToAdd.put(qv.Large_Product__c, String.valueOf(newQuantity));
                }

                Decimal quantityRemoved = qvQuantity * newQuantity;

                quantity -= quantityRemoved;

                if (quantity == 0) break;
            }

            if (quantity != 0) {
                Decimal pQuantity = quantity / p.Unit_Quantity__c;
                productsToUpdate.put(p.Id, String.valueOf(pQuantity));
            }
            else {
                productsToRemove.add(p.Id);
            }
        }

        addItemsToCart(productsToAdd, effectiveAccountId);

        for (ConnectApi.CartItemResult res : cartItems.cartItems) {
            Id cartItemId = res.cartItem.cartItemId;
            Id productId = res.cartItem.productDetails.productId;

            if (productsToUpdate.keySet().contains(productId)) {
                ConnectApi.CartItemInput input = new ConnectApi.CartItemInput();
                input.quantity = productsToUpdate.get(productId);
                updateCartItem(communityId, effectiveAccountId, activeCartOrId, cartItemId, input);
            }

            if (productsToRemove.contains(productId)) {
                deleteCartItem(communityId, effectiveAccountId, activeCartOrId, cartItemId);
            }
        }
    }

    /**
     * @description Demonstrates how to call ConnectApi.CommerceCart.deleteCartItem
     * @param  communityId The Id of the community from which the call originated
     * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
     * @param activeCartOrId ID of the cart, active, or current.
     * @param cartItemId ID of the cart item to be deleted.
     */
    @AuraEnabled
    public static void deleteCartItem(
            String communityId,
            String effectiveAccountId,
            String activeCartOrId,
            String cartItemId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        ConnectApi.CommerceCart.deleteCartItem(
                webstoreId,
                effectiveAccountId,
                activeCartOrId,
                cartItemId
        );
    }

    /**
     * @description Demonstrates how to call ConnectApi.CommerceCart.getCartSummary
     * @param  communityId The Id of the community from which the call originated
     * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
     * @param activeCartOrId ID of the cart, active, or current.
     */
    @AuraEnabled
    public static ConnectApi.CartSummary getCartSummary(
            String communityId,
            String effectiveAccountId,
            String activeCartOrId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        return ConnectApi.CommerceCart.getCartSummary(
                webstoreId,
                effectiveAccountId,
                activeCartOrId
        );
    }

    @AuraEnabled
    public static Decimal getDiscount(String activeCartOrId) {
        return [SELECT XC_TotalDiscount__c FROM WebCart WHERE Id = :activeCartOrId].XC_TotalDiscount__c;
    }

    /**
     * @description Demonstrates how to call ConnectApi.CommerceCart.createCart
     * @param  communityId The Id of the community from which the call originated
     * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
     */
    @AuraEnabled
    public static ConnectApi.CartSummary createCart(
            String communityId,
            String effectiveAccountId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        ConnectApi.CartInput cartInput = new ConnectApi.CartInput();
        cartInput.effectiveAccountId = effectiveAccountId;
        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        return ConnectApi.CommerceCart.createCart(webstoreId, cartInput);
    }

    /**
     * @description Demonstrates how to call ConnectApi.CommerceCart.deleteCart
     * @param  communityId The Id of the community from which the call originated
     * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
     * @param activeCartOrId ID of the cart, active, or current.
     */
    @AuraEnabled
    public static void deleteCart(
            String communityId,
            String effectiveAccountId,
            String activeCartOrId
    ) {
        // Lookup the webstore ID associated with the community
        String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

        // For more details, see:
        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
        ConnectApi.CommerceCart.deleteCart(
                webstoreId,
                effectiveAccountId,
                activeCartOrId
        );
    }
}