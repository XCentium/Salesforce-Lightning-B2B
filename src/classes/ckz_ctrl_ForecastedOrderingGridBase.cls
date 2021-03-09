global with sharing class ckz_ctrl_ForecastedOrderingGridBase {
    
@RemoteAction
    global static ccrz.cc_RemoteActionResult processOrderItems(ccrz.cc_RemoteActionContext ctx, String jsonData) {

        ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ctrl_ForecastedOrderingGrid:processOrderItems', 'saveACHNumber');
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ctrl_ForecastedOrderingGrid:processOrderItems', 'jsonData: ' + jsonData);

        ccrz.cc_CallContext.initRemoteContext(ctx);

        ccrz.cc_RemoteActionResult response = new ccrz.cc_RemoteActionResult();
        Boolean isSuccess = false;
        Contact theContact = null;

        List<ccrz.cc_bean_Message> retMessages = new List<ccrz.cc_bean_Message>();

        try
        {
            List<Map<String,Object>> formData = (List<Map<String,Object>>)JSON.deserializeUntyped(jsonData);

            for(Map<String, Object> row : formData) {
                String sku = (String)row.get('sku');
                String qty = (String)row.get('qty');
                String requestedDate = (String)row.get('requestedDate');

                ccrz.ccLog.log(System.LoggingLevel.INFO, 'ckz_ctrl_ForecastedOrderingGridBase:processOrderItems', 'item: ' + sku + ' / ' + qty + ' / ' + requestedDate);
                System.debug('item: ' + sku + ' / ' + qty + ' / ' + requestedDate);

            }

            

            update theContact;

            ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message();
            //msg.labelId              = 'BudgetOverrideApproved' ;
            msg.message = 'Changes successfully saved for user: ' + theContact.FirstName + ' ' + theContact.LastName;
            msg.type                 = ccrz.cc_bean_Message.MessageType.CUSTOM ;
            msg.severity             = ccrz.cc_bean_Message.MessageSeverity.INFO ;
            msg.classToAppend        = 'messagingSection-UserRoles-Info';

            retMessages.add(msg);

            isSuccess = true;

        } catch (Exception ex) {
            System.debug('ckz_ctrl_ForecastedOrderingGrid:processOrderItems:responseFalse');
            isSuccess = false;
            System.debug('message: ' + ex.getMessage());
            System.debug('line: ' + ex.getLineNumber());

            ccrz.cc_bean_Message msgErr = new ccrz.cc_bean_Message();
            msgErr.message = 'Error processing items';
            msgErr.severity = ccrz.cc_bean_Message.MessageSeverity.ERROR;
            msgErr.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
            msgErr.classToAppend = 'messagingSection-UserRoles-Info';
            retMessages.add(msgErr);

        } finally {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:X', 'processOrderItems');
            ccrz.ccLog.close(response);

            response.success = isSuccess;
            response.inputContext = ctx;
            response.messages.addAll(retMessages);
            response.data = null;

        }

        ccrz.ccLog.log('ckz_ctrl_ForecastedOrderingGrid:processOrderItems:response: ' + response);
        return response;

    }

}