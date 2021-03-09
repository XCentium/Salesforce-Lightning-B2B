/**
 * Created by brandon.rogers on 4/22/19.
 */

global with sharing class ckz_ctrl_LastOrder {

    Public Static String storeFrontName;
    Public Static String brand = 'Brand';
    Public Static String category = 'Category';

    /*
    public ckz_ctrl_LastOrder(ckz_ctrl_ProductList controller) {

    }*/

    public String userLocale { get; set; }
    public ckz_ctrl_LastOrder() {
        // System.debug('----------------'+UserInfo.getLocale());
        userLocale = UserInfo.getLocale();
        storeFrontName = ccrz.cc_CallContext.storefront;

    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult retrieveLastOrder(ccrz.cc_RemoteActionContext ctx) {
        ccrz.cc_RemoteActionResult result = ckz_util_Utils.initAction(ctx);

        try {
            // Get logged in userid
            String userId = (String.isBlank(ctx.portalUserId)) ? UserInfo.getUserId() : ctx.portalUserId;
            String cartId = (String.isBlank(ctx.currentCartID)) ? '' : ctx.currentCartID;

            // Retrieve a list of cart items in the current cart
            System.debug('==== Make call to retrieveCartItems');
            ckz_util_OrderBuilder orderBuilderUtil = new ckz_util_OrderBuilder();
            ccrz__E_Cart__c currentCartData = orderBuilderUtil.retrieveCurrentCart(cartId);

            // Set list of orders to the result
            System.debug('==== Make call to retrieveOrders');

            String storefront = ctx.storefront;

            //List<ckz_bean_Order> orders = orderBuilderUtil.retrieveOrders(1, currentCartData);
            List<ckz_bean_Order> orders = orderBuilderUtil.retrieveOrders(1, storefront, currentCartData);

            //****List<ckz_bean_Order> orders = null;

            ckz_bean_Order order = new ckz_bean_Order();

            if (orders.size() > 0) {
                order = orders.get(0);
                result.data = order;
                result.success = true;
            } else {
                result.data = false;
                result.success = false;
            }
        } catch (Exception e) {
            System.debug(System.LoggingLevel.INFO, '===== error message ' + e.getMessage());
            System.debug(System.LoggingLevel.INFO, '===== stack trace ' + e.getStackTraceString());
            result.messages.add(ckz_util_Utils.buildExceptionMessage(e));
        }
        return result;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult setProductType(ccrz.cc_RemoteActionContext ctx, String cartId) {
        ccrz.cc_RemoteActionResult result = ckz_util_Utils.initAction(ctx);
        try {
            ckz_util_OrderBuilder orderBuilderUtil = new ckz_util_OrderBuilder();

            ccrz__E_Cart__c currentCartData = orderBuilderUtil.retrieveCurrentCart(cartId);
            //****ccrz__E_Cart__c currentCartData = null;

            List<ccrz__E_CartItem__c> cartItems = currentCartData.getSObjects('ccrz__E_CartItems__r');

            if (cartItems != null) {
                List<ccrz__E_CartItem__c> lstRecords = new List<ccrz__E_CartItem__c>();
                for (ccrz__E_CartItem__c cartItem : cartItems) {
                    cartItem.ccrz__ProductType__c = 'Product';
                    lstRecords.add(cartItem);
                }
                update lstRecords;
            }
            result.success = true;

        } catch (Exception e) {
            System.debug(System.LoggingLevel.INFO, e.getMessage());
            System.debug(System.LoggingLevel.INFO, e.getStackTraceString());
            result.messages.add(ckz_util_Utils.buildExceptionMessage(e));
        }
        return result;
    }


    /* Start- To get the Brand and category of Product- Google Analytics */
    @RemoteAction
    global static List<String> findBrandCategory(String sku) {
        String[] strList1 = new String[2];
        strlist1[0] = null;
        strlist1[1] = null;
        List<ccrz__E_ProductSpec__c> prdSpec = [
                select id,ccrz__SpecValue__c,ccrz__Spec__r.name
                from ccrz__E_ProductSpec__c
                where ccrz__Product__r.ccrz__SKU__c = :sku and
                //BottlerName__c=:storeFrontName and
                (ccrz__Spec__r.name = :brand OR ccrz__Spec__r.name = :category)
                LIMIT 2
        ];

        Map<String, String> newMap = new Map<String, String>();
        try {
            if (!prdSpec.isEmpty()) {
                for (ccrz__E_ProductSpec__c cc : prdSpec) {
                    newMap.put(cc.ccrz__Spec__r.name, cc.ccrz__SpecValue__c);

                }

                if (newMap.containsKey(brand)) {
                    strList1[0] = newMap.get(brand);
                }
                if (newMap.containsKey(category)) {
                    strList1[1] = newMap.get(category);
                }
                return strList1;
            }

        } catch (Exception e) {
            System.debug('exception===>>>>' + e.getLineNumber() + '====' + e.getMessage());
        }
        return strList1;
    }
    public map<string, Map<String, String>> findMapBrandCategory1(List<string> listsku) {
        System.debug('listsku====' + listsku);
        List<ccrz__E_ProductSpec__c> prdSpec = [
                select id,ccrz__SpecValue__c,ccrz__Spec__r.name,ccrz__Product__r.ccrz__SKU__c
                from ccrz__E_ProductSpec__c
                where ccrz__Product__r.ccrz__SKU__c IN :listsku
                //and BottlerName__c=:storeFrontName
                and (ccrz__Spec__r.name = :brand OR ccrz__Spec__r.name = :category)
                LIMIT 100
        ];
        System.debug('prdSpec====' + prdSpec);
        Map<String, String> mapBrandandCat = new Map<String, String>();
        map<string, Map<String, String>> mapSku = new map<string, Map<String, String>>();
        try {
            if (!prdSpec.isEmpty()) {

                for (ccrz__E_ProductSpec__c cc : prdSpec) {

                    if (mapsku.containsKey(cc.ccrz__Product__r.ccrz__SKU__c)) {
                        Map<String, String> maplocalBrandandCat = new Map<String, String>();
                        maplocalBrandandCat = mapsku.get(cc.ccrz__Product__r.ccrz__SKU__c);
                        Map<String, String> maplocalBrandandCat2 = new Map<String, String>();
                        maplocalBrandandCat2.put(cc.ccrz__Spec__r.name, cc.ccrz__SpecValue__c);
                        maplocalBrandandCat.putAll(maplocalBrandandCat2);
                        mapsku.put(cc.ccrz__Product__r.ccrz__SKU__c, maplocalBrandandCat);
                    } else {

                        mapBrandandCat.put(cc.ccrz__Spec__r.name, cc.ccrz__SpecValue__c);
                        mapsku.put(cc.ccrz__Product__r.ccrz__SKU__c, mapBrandandCat);
                    }


                }
                return mapsku;

            }

        } catch (Exception e) {
            System.debug('exception===>>>>' + e.getLineNumber() + '====' + e.getMessage());
        }
        return mapsku;
    }
    /* End- To get the Brand and category of Product- Google Analytics */

}