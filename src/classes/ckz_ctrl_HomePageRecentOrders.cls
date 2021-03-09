global with sharing class ckz_ctrl_HomePageRecentOrders {

    @RemoteAction
    global static ccrz.cc_RemoteActionResult getOrders(ccrz.cc_RemoteActionContext ctx, String maxOrders) {
        
        ccrz.cc_CallContext.init(ctx);

        ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckz_ctrl_HomePageRecentOrders', 'getOrders: begin');

        ccrz.ccLog.log(LoggingLevel.INFO, 'ckz_ctrl_HomePageRecentOrders', 'ctx: ' + ctx);
        System.debug('ctx: ' + ctx);

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);
        result.success = false;
        result.inputContext = ctx;

        String effectiveAccountId = '';

        if (ctx.effAccountId != null && ctx.effAccountId != '') {
            effectiveAccountId = ctx.effAccountId;
        } else {
            effectiveAccountId = ccrz.cc_CallContext.effAccountId;
        }

// Default to five
        Integer orderTot = 5;

        if (maxOrders.isNumeric()) {
            orderTot = Integer.valueOf(maxOrders);
        }

        String ownerId = ccrz.cc_CallContext.currUserId;

        System.debug('ownerId = ' + ownerId);
        System.debug('storefront = ' + ctx.storefront);

        Map<String, Object> dataMap = new Map<String, Object>();

        List<Map<String, Object>> dataList = new List<Map<String, Object>>();

        List<ccrz.cc_bean_Message> retMessages = new List<ccrz.cc_bean_Message>();

        Map<String, Object> inputData = new Map<String, Object>{
//ccrz.ccAPIOrder.PARAM_ORDER_EFFACCT_ID => effectiveAccountId
                ccrz.ccAPIOrder.PARAM_OWNERID => ownerId
                , ccrz.ccAPIOrder.PARAM_STOREFRONT => ctx.storefront
                //, ccrz.ccAPI.API_VERSION => 7
                ,ccrz.ccAPI.API_VERSION => ccrz.ccApi.CURRENT_VERSION
                , ccrz.ccAPIOrder.PARAM_BY_DATE => TRUE
                    
                ,ccrz.ccApi.SIZING => new Map<String, Object>{
                    ccrz.ccAPIProduct.ENTITYNAME => new Map<String, Object>{
                        ccrz.ccApi.SZ_DATA => ccrz.ccApi.SZ_L
                   }
                }
        };

        try {
            Map<String, Object> outputData = ccrz.ccAPIOrder.fetch(inputData);
            if (outputData.get(ccrz.ccAPIOrder.ORDERLIST) != null) {

                List<Map<String, Object>> outputOrderList = (List<Map<String, Object>>) outputData.get(ccrz.ccAPIOrder.ORDERLIST);

                for (integer i = 0; (i < outputOrderList.size()) && (i < orderTot); i++) {

                    Map<String, Object> orderMap = (Map<String, Object>) outputOrderList.get(i);

                    /*
                    if (orderMap.get('orderDate') != null) {
                        Date orderItemDate = Date.valueOf((String) orderMap.get('orderDate'));
                        orderMap.put('orderDateStr', orderItemDate.format());
                    } else {
                        orderMap.put('orderDateStr', '');
                    }
                    */
                    
                    Object orderDate = orderMap.get('orderDate');

                    if(orderDate instanceof DateTime) {
                        orderMap.put('orderDateStr', ((DateTime)orderDate).format());
                    }
                    else {
                        Date orderItemDate = Date.valueOf((String) orderMap.get('orderDate'));
                        orderMap.put('orderDateStr', orderItemDate.format());
                    }
                    

                    dataList.add(orderMap);

                }

                dataMap.put('orderList', dataList);

                result.data = dataMap;
                result.success = true;
            }

//            ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message();
//
//            msg.message = 'Data Retrieved';
//            msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM ;
//            msg.severity = ccrz.cc_bean_Message.MessageSeverity.INFO ;
//            msg.classToAppend = 'messagingSection-Reorder-Info';
//
//            retMessages.add(msg);


        } catch (Exception ex) {
            ccrz.ccLog.log('ckz_ctrl_HomePageRecentOrders', 'getOrders:responseFalse');
            result.success = false;
            result.data = null;

            ccrz.ccLog.log(LoggingLevel.ERROR, 'ckz_ctrl_HomePageReorder', 'message: ' + ex.getMessage());

            ccrz.cc_bean_Message msgErr = new ccrz.cc_bean_Message();
            msgErr.message = 'Error getting orders: ' + ex.getMessage();
            msgErr.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
            msgErr.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
            msgErr.classToAppend = 'messagingSection-Reorder-Info';
            retMessages.add(msgErr);

        } finally {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ctrl_HomePageRecentOrders', 'getOrders');
            ccrz.ccLog.close(result);

            result.messages.addAll(retMessages);
        }

        System.debug('getOrders:result: ' + result);
        ccrz.ccLog.log('ckz_ctrl_HomePageRecentOrders', ':getOrders:result: ' + result);
        return result;
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult reorder(ccrz.cc_RemoteActionContext ctx, String orderId, String sfdcName) {

        ccrz.cc_RemoteActionResult result = ccrz.cc_CallContext.init(ctx);

        Map<String, Object> inputMap = new Map<String, Object>{
                ccrz.ccAPI.API_VERSION => 7,
                ccrz.ccAPIOrder.PARAM_ORDER_ID => orderId

        };

        Boolean isSuccess = false;
        List<ccrz.cc_bean_Message> retMessages = new List<ccrz.cc_bean_Message>();
        String encrCartId = null;

        try {
            Map<String, Object> res = (Map<String, Object>) ccrz.ccAPIOrder.reorder(inputMap);
            System.debug((Boolean) res.get(ccrz.ccAPI.SUCCESS));
            Boolean success = (Boolean) res.get(ccrz.ccAPI.SUCCESS);

            List<ccrz.cc_bean_Message> messages = (List<ccrz.cc_bean_Message>) res.get(ccrz.ccAPI.MESSAGES);
            System.debug('messages: ' + messages);

            Id cartId = (Id) res.get(ccrz.ccAPICart.CART_ID);
            System.debug('cartId: ' + cartId);

            encrCartId = (String) res.get(ccrz.cc_hk_Order.PARAM_ENC_CART_ID);

// Reprice the cart
            Map<String, Object> cartPriceInputMap = new Map<String, Object>{
                    ccrz.ccAPI.API_VERSION => 7,
                    ccrz.ccApiCart.CART_ENCID => encrCartId

            };
            Map<String, Object> res2 = (Map<String, Object>) ccrz.ccApiCart.price(cartPriceInputMap);

            ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message();
//msg.labelId              = 'BudgetOverrideApproved' ;
            msg.message = 'Order added to the cart: ' + sfdcName;
            msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM ;
            msg.severity = ccrz.cc_bean_Message.MessageSeverity.INFO ;
            msg.classToAppend = 'messagingSection-Reorder-Info';

            retMessages.add(msg);

            isSuccess = true;

        } catch (Exception ex) {
            System.debug('ckz_ctrl_HomePageRecentOrders:reorder:responseFalse');
            isSuccess = false;
            System.debug('message: ' + ex.getMessage());

            ccrz.cc_bean_Message msgErr = new ccrz.cc_bean_Message();
            msgErr.message = 'Error placing the reorder for: ' + sfdcName;
            msgErr.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
            msgErr.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
            msgErr.classToAppend = 'messagingSection-Reorder-Info';
            retMessages.add(msgErr);

        } finally {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ctrl_HomePageRecentOrders', 'reorder');
            ccrz.ccLog.close(result);

            result.success = isSuccess;
            result.inputContext = ctx;
            result.messages.addAll(retMessages);
            result.data = encrCartId;

        }

        ccrz.ccLog.log(LoggingLevel.INFO, 'M:X', 'ckz_ctrl_HomePageRecentOrders: reorder completed');

        return result;

    }

}