/**
 * Created by brandon.rogers on 4/16/19.
 */

global with sharing class ckz_ctrl_pmt_ACH_New {

    @RemoteAction
    global static ccrz.cc_RemoteActionResult saveACHNumber(ccrz.cc_RemoteActionContext ctx, String jsonData) {
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'saveACHNumber');
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'D:jsonData', jsonData);
        ccrz.cc_RemoteActionResult result = new ccrz.cc_RemoteActionResult();
        result.success = false;
        result.inputContext = ctx;

        try {
            Map<String, Object> formData = (Map<String, Object>) JSON.deserializeUntyped(jsonData);

            ccrz.ccLog.log(System.LoggingLevel.INFO, 'formData', formData);

            ccrz__E_StoredPayment__c pmt = new ccrz__E_StoredPayment__c(
                    ccrz__Account__c = ccrz.cc_CallContext.effAccountId,
                    ccrz__User__c = ccrz.cc_CallContext.currUserId,
                    ccrz__Storefront__c = ccrz.cc_CallContext.storefront,

                    ccrz__SubaccountNumber__c = (String) formData.get('routingNumber'),
                    ccrz__AccountNumber__c = (String) formData.get('accountNumber'),

                    ccrz__AccountType__c = (String) formData.get('accountType'),  // cc, po, ach
                    ccrz__DisplayName__c = (String) formData.get('displayName'),

                    ccrz__Enabled__c = formData.get('isEnabled') != null ? true : false
            );

            ccrz.ccLog.log(System.LoggingLevel.INFO, 'pmt', pmt);

            insert pmt;

            result.success = true;

        } catch (exception e) {
            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ERR', e);

        } finally {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:X', 'saveACHNumber');
            ccrz.ccLog.close(result);
        }

        return result;
    }

}