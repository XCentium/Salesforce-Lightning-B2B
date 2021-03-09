/**
 * @FileName: XC_LWC_CartCtrlHelper
 * @Description: Helper methods for lightning storefront cart controller
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/15/2020         Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_LWC_CartCtrlHelper {

    public static ConnectApi.CartItem addItemToCart(String productId, String quantity, String effectiveAccountId) {
        ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
        cartInput.productId = productId;
        cartInput.quantity = quantity;
        cartInput.type = ConnectApi.CartItemType.PRODUCT;

        ConnectApi.CartItem result = ConnectApi.CommerceCart.addItemToCart(
                XC_Util_Query.currentWebStoreId,
                effectiveAccountId,
                'active',
                cartInput
        );

        return result;
    }

    public static List<ConnectApi.BatchResult> addItemsToCart(Map<String,String> items, String effectiveAccountId) {
        List<ConnectApi.BatchInput> cartItems = new List<ConnectApi.BatchInput>();

        for (String productId : items.keySet()) {
            String qty = items.get(productId);

            if (String.isBlank(qty)) continue;

            ConnectApi.CartItemInput item = new ConnectApi.CartItemInput();
            item.productId = productId;
            item.quantity = items.get(productId);
            item.type = ConnectApi.CartItemType.PRODUCT;

            cartItems.add(new ConnectApi.BatchInput(item));
        }

        List<ConnectApi.BatchResult> results = ConnectApi.CommerceCart.addItemsToCart(XC_Util_Query.currentWebStoreId, effectiveAccountId, 'active', cartItems);

        return results;
    }
}