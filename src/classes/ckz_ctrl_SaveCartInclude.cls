global with sharing class ckz_ctrl_SaveCartInclude {

    @RemoteAction
    global static ccrz.cc_RemoteActionResult saveCart(final ccrz.cc_RemoteActionContext ctx, String cartId, String cartName) {

        ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckz_ctrl_SaveCartInclude', 'saveCart');

        ccrz.cc_CallContext.initRemoteContext(ctx);

        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;

        Map<String, Object> data = new Map<String, Object>();

        List<ccrz.cc_bean_Message> retMessages = new List<ccrz.cc_bean_Message>();

        try {

            List<String> cartidlist = new List<String>{};
            cartidlist.add(ctx.currentCartId);


            Map<String, Object> cartInputData = new Map<String, Object>{
                    'sfid' => cartId
                    ,'cartStatus' => 'Open'
                    ,'activeCart' => false
            };

            if(cartName != null && cartName != '') {
                cartInputData.put('name', cartName);
            }

            List<Object> cartReviseList = new List<Object>();
            cartReviseList.add(cartInputData);

            Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
                    , ccrz.ccApiCart.CART_OBJLIST => cartReviseList
            };

            Map<String, Object> outputData = ccrz.ccApiCart.revise(inputData);

            System.debug('outputData: ' + outputData);

            Boolean wasSuccessful = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            System.debug('wasSuccessful = ' + wasSuccessful);

            ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckz_ctrl_SaveCartInclude', 'wasSuccessful = ' + wasSuccessful);

            // Create a new cart
            String cartEncrId = createNewCart();
            data.put('cartEncrId', cartEncrId);

            res.success = true;

            String messageText = 'Cart saved!';
            ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(messageText, ccrz.cc_bean_Message.MessageSeverity.INFO);
            msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
            msg.classToAppend = 'messagingSection-Info';

            retMessages.add(msg);

        }
        catch (Exception ex) {
            data.put('exception', ex);
            System.debug(System.LoggingLevel.ERROR, ex.getMessage());
            System.debug(System.LoggingLevel.ERROR, ex.getStackTraceString());

            ccrz.ccLog.log('ckz_ctrl_SaveCartInclude', 'saveCart:' + ex.getMessage());

            ccrz.ccLog.log(LoggingLevel.ERROR, 'message', ex.getMessage());

            String messageText = 'Cart save error: ' + ex.getMessage();
            ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(messageText, ccrz.cc_bean_Message.MessageSeverity.ERROR);
            msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
            msg.classToAppend = 'messagingSection-Error';
            retMessages.add(msg);

        }
        finally {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ctrl_SaveCartInclude', 'saveCart');
            ccrz.ccLog.close(res);

            res.messages.addAll(retMessages);
            res.data = data;
        }

        return res;
    }

    private static String createNewCart() {

        Map<String, Object> inputData = new Map<String, Object>{
                ccrz.ccApi.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
        };

        Map<String, Object> outputData = ccrz.ccApiCart.create(inputData);

        System.debug('outputData: ' + outputData);

        Boolean wasSuccessful = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

        System.debug('wasSuccessful = ' + wasSuccessful);
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckz_ctrl_SaveCartInclude', 'createNewCart: wasSuccessful = ' + wasSuccessful);

        String cartEncrId = (String)outputData.get(ccrz.ccApiCart.CART_ENCID);

        ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckz_ctrl_SaveCartInclude', 'createNewCart: cartEncrId = ' + cartEncrId);

        return cartEncrId;

    }

}