/*
   @Author: EDL Resource
   @Updated By: Accenture, modified to sort Products Order Builder - Phase-3 Release-1
   @Name: ckz_ctrl_OrderBuilder
   @CreateDate: 11/11/2014
   @Description:ckz_ctrl_OrderBuilder
   @Version: 1.0
 */

global with sharing class ckz_ctrl_OrderBuilder {
    public ckz_ctrl_OrderBuilder() {
        System.debug(LoggingLevel.INFO, 'retrieveOrders:start');
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult retrieveOrders(ccrz.cc_RemoteActionContext ctx, String sortBy, Boolean order) {
        ccrz.cc_RemoteActionResult result = ckz_util_Utils.initAction(ctx);
        ccrz.ccLog.log(LoggingLevel.INFO, 'M:E', 'retrieveOrders');
        System.debug(LoggingLevel.INFO, 'retrieveOrders');
        try {
            // Get logged in userid
            String userId = (String.isBlank(ctx.portalUserId)) ? UserInfo.getUserId() : ctx.portalUserId;
            String cartId = (String.isBlank(ctx.currentCartID)) ? '' : ctx.currentCartID;

            // Retrieve a list of cart items in the current cart

            ckz_util_OrderBuilder orderBuilderUtil = new ckz_util_OrderBuilder();
            ccrz__E_Cart__c currentCartData = orderBuilderUtil.retrieveCurrentCart(cartId);

            // Set list of orders to the result

            String storefront = ctx.storefront;

            List<ckz_bean_Order> orders = orderBuilderUtil.retrieveOrders(6, storefront, currentCartData);


            // Sort the orders in ascending order for display purposes
            orders.sort();

            // Build a map of unique order items by the passed in list of orders

            Map<String, ckz_bean_OrderItem> uniqueOrderItemMap = orderBuilderUtil.buildUniqueOrderItemMap(orders);


            // Build a list of orderBuilderMaps
            List<ckz_bean_OrderBuilderMap> orderBuilderMapList = orderBuilderUtil.buildOrderBuilderMapList(uniqueOrderItemMap, orders);

            //for(List<ckz_bean_OrderBuilderMap> listOBM:orderBuilderMapList){

            //}
            if (sortBy == '2')
                ckz_bean_OrderBuilderMap.sortBy = ckz_bean_OrderBuilderMap.SORT_BY.ByArticleCode; else if (sortBy == '1')
                ckz_bean_OrderBuilderMap.sortBy = ckz_bean_OrderBuilderMap.SORT_BY.ByTradeMark; else if (sortBy == '3')
                ckz_bean_OrderBuilderMap.sortBy = ckz_bean_OrderBuilderMap.SORT_BY.ByUnitOfMeasure;

            if (order)
                ckz_bean_OrderBuilderMap.ascOrder = true; else
                    ckz_bean_OrderBuilderMap.ascOrder = false;

            orderBuilderMapList.sort();


            // Build out the wrapper for front end to handle
            ckz_bean_OrderBuilderWrapper orderBuilderWrapper = new ckz_bean_OrderBuilderWrapper(orderBuilderMapList, orders);

            result.data = orderBuilderWrapper;
            result.success = true;

        } catch (Exception e) {
            System.debug(System.LoggingLevel.INFO, e.getMessage());
            System.debug(System.LoggingLevel.INFO, e.getStackTraceString());
            result.messages.add(ckz_util_Utils.buildExceptionMessage(e));
            ccrz.ccLog.log(LoggingLevel.ERROR, 'ERR', e);
        } finally {
            ccrz.ccLog.log(LoggingLevel.INFO, 'M:X', 'retrieveOrdersEND');
            ccrz.ccLog.close(result);
        }
        return result;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult setProductType(ccrz.cc_RemoteActionContext ctx, String cartId) {
        ccrz.cc_RemoteActionResult result = ckz_util_Utils.initAction(ctx);
        try {
            ckz_util_OrderBuilder orderBuilderUtil = new ckz_util_OrderBuilder();
            ccrz__E_Cart__c currentCartData = orderBuilderUtil.retrieveCurrentCart(cartId);

            List<ccrz__E_CartItem__c> cartItems = currentCartData.getSObjects('ccrz__E_CartItems__r');
            List<ccrz__E_CartItem__c> cartItm = new List<ccrz__E_CartItem__c>();
            if (cartItems != null) {
                for (ccrz__E_CartItem__c cartItem : cartItems) {
                    cartItem.ccrz__ProductType__c = 'Product';
                    cartItm.add(cartItem);

                }
            }
            update cartItm;
            result.success = true;

        } catch (Exception e) {
            System.debug(System.LoggingLevel.INFO, e.getMessage());
            System.debug(System.LoggingLevel.INFO, e.getStackTraceString());
            result.messages.add(ckz_util_Utils.buildExceptionMessage(e));
        }
        return result;
    }
}