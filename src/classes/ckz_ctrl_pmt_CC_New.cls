/**
 * Created by brandon.rogers on 3/29/19.
 */

global with sharing class ckz_ctrl_pmt_CC_New {
    global String dummy { get; set; }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult saveCCNumber(ccrz.cc_RemoteActionContext ctx, String jsonCCData) {
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'saveCCNumber');
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'D:jsonCCData', jsonCCData);
        ccrz.cc_RemoteActionResult result = new ccrz.cc_RemoteActionResult();
        result.success = false;
        result.inputContext = ctx;

        try {
            Map<String, Object> formData = (Map<String, Object>) JSON.deserializeUntyped(jsonCCData);

            ccrz.ccLog.log(System.LoggingLevel.INFO, 'formData', formData);

            ccrz__E_StoredPayment__c pmt = new ccrz__E_StoredPayment__c(
                    ccrz__Account__c = ccrz.cc_CallContext.effAccountId,
                    ccrz__User__c = ccrz.cc_CallContext.currUserId,
                    ccrz__Storefront__c = ccrz.cc_CallContext.storefront,
                    ccrz__AccountNumber__c = (String) formData.get('accountNumber'),
                    ccrz__AccountType__c = (String) formData.get('accountType'),
                    ccrz__DisplayName__c = (String) formData.get('displayName'),
                    ccrz__PaymentType__c = (String) formData.get('paymentType'),
                    ccrz__ExpMonth__c = Decimal.valueOf((String) formData.get('expirationMonth')),
                    ccrz__ExpYear__c = Decimal.valueOf((String) formData.get('expirationYear')),
                    ccrz__Enabled__c = formData.get('isEnabled') != null ? true : false
            );

            ccrz.ccLog.log(System.LoggingLevel.INFO, 'pmt', pmt);

            insert pmt;

            result.success = true;

        } catch (exception e) {
            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ERR', e);

        } finally {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:X', 'saveCCNumber');
            ccrz.ccLog.close(result);
        }

        return result;
    }
}