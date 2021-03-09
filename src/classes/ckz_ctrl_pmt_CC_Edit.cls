/**
 * Created by brandon.rogers on 3/29/19.
 */

global with sharing class ckz_ctrl_pmt_CC_Edit {
    public String displayName { get; set; }
    public String accountNumber { get; set; }
    public Boolean isEnabled { get; set; }
    public String storedPaymentId { get; set; }
    public Decimal expMonth { get; set; }
    public Decimal expYear { get; set; }
    public String paymentType { get; set; }

    public ckz_ctrl_pmt_CC_Edit() {
        storedPaymentId = ApexPages.currentPage().getParameters().get('pid');
        initStoredPayment();
    }

    public void initStoredPayment() {
        List<ccrz__E_StoredPayment__c> payments = [
                select ccrz__DisplayName__c,
                        ccrz__AccountNumber__c,
                        ccrz__Enabled__c,
                        ccrz__PaymentType__c,
                        ccrz__ExpMonth__c,
                        ccrz__ExpYear__c
                from ccrz__E_StoredPayment__c
                where Id = :storedPaymentId
        ];

        if (payments.size() > 0) {
            ccrz__E_StoredPayment__c sp = payments[0];
            displayName = sp.ccrz__DisplayName__c;
            accountNumber = sp.ccrz__AccountNumber__c;
            isEnabled = sp.ccrz__Enabled__c;
            expMonth = sp.ccrz__ExpMonth__c;
            expYear = sp.ccrz__ExpYear__c;
            paymentType = sp.ccrz__PaymentType__c;
        }
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateCCNumber(ccrz.cc_RemoteActionContext ctx, String jsonCCData) {
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'updateCCNumber');
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'D:jsonCCData', jsonCCData);
        ccrz.cc_RemoteActionResult result = new ccrz.cc_RemoteActionResult();
        result.success = true;
        result.inputContext = ctx;

        try {
            Map<String, Object> formData = (Map<String, Object>) JSON.deserializeUntyped(jsonCCData);

            Id pid = (Id) formData.get('storedPaymentId');

            List<ccrz__E_StoredPayment__c> payments = [select ccrz__DisplayName__c, ccrz__AccountNumber__c, ccrz__Enabled__c from ccrz__E_StoredPayment__c where Id = :pid and ccrz__ReadOnly__c = false];

            if (!payments.isEmpty()) {
                ccrz__E_StoredPayment__c pmt = new ccrz__E_StoredPayment__c(
                        id = pid,
                        ccrz__DisplayName__c = (String) formData.get('displayName'),
                        ccrz__Enabled__c = formData.get('isEnabled') != null ? true : false,
                        ccrz__ExpMonth__c = Decimal.valueOf((String) formData.get('expirationMonth')),
                        ccrz__ExpYear__c = Decimal.valueOf((String) formData.get('expirationYear'))
                );

                update pmt;
            } else {
                ccrz.ccLog.log(System.LoggingLevel.WARN, 'WARN', 'No matching stored payments were found to update');
                result.success = false;
            }
        } catch (Exception e) {
            ccrz.ccLog.log(System.LoggingLevel.ERROR, 'ERR', e);
            result.success = false;
        } finally {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:X', 'updateCCNumber');
            ccrz.ccLog.close(result);
        }

        return result;
    }
}