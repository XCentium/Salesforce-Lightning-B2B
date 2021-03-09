/**
 * Created by brandon.rogers on 4/16/19.
 */

global with sharing class ckz_ctrl_pmt_ACH_Edit {

    public String accountNumber { get; set; }
    public String routingNumber { get; set; }
    public String displayName { get; set; }

    public Boolean isEnabled { get; set; }
    public String storedPaymentId { get; set; }

    public ckz_ctrl_pmt_ACH_Edit() {
        storedPaymentId = ApexPages.currentPage().getParameters().get('pid');
        initStoredPayment();
    }

    public void initStoredPayment() {
        List<ccrz__E_StoredPayment__c> payments = [
                select ccrz__DisplayName__c,
                        ccrz__Enabled__c,
                        ccrz__AccountType__c,
                        ccrz__SubaccountNumber__c,
                        ccrz__AccountNumber__c
                from ccrz__E_StoredPayment__c
                where Id = :storedPaymentId
        ];

        if (payments.size() > 0) {
            ccrz__E_StoredPayment__c sp = payments[0];

            isEnabled = sp.ccrz__Enabled__c;
            accountNumber = sp.ccrz__AccountNumber__c;
            routingNumber = sp.ccrz__SubaccountNumber__c;
            displayName = sp.ccrz__DisplayName__c;
        }
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult updateACHNumber(ccrz.cc_RemoteActionContext ctx, String jsonData) {
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:E', 'updateACHNumber');
        ccrz.ccLog.log(System.LoggingLevel.INFO, 'D:jsonData', jsonData);
        ccrz.cc_RemoteActionResult result = new ccrz.cc_RemoteActionResult();
        result.success = true;
        result.inputContext = ctx;

        try {
            Map<String, Object> formData = (Map<String, Object>) JSON.deserializeUntyped(jsonData);

            Id pid = (Id) formData.get('storedPaymentId');

            List<ccrz__E_StoredPayment__c> payments = [
                    select ccrz__DisplayName__c,
                            ccrz__SubaccountNumber__c,
                            ccrz__AccountNumber__c,
                            ccrz__Enabled__c
                    from ccrz__E_StoredPayment__c
                    where Id = :pid
                    and ccrz__ReadOnly__c = false
            ];

            if (!payments.isEmpty()) {
                ccrz__E_StoredPayment__c pmt = new ccrz__E_StoredPayment__c(
                        id = pid,
                        ccrz__DisplayName__c = (String) formData.get('displayName'),
                        ccrz__Enabled__c = formData.get('isEnabled') != null ? true : false,
                        ccrz__SubaccountNumber__c = (String) formData.get('routingNumber'),
                        ccrz__AccountNumber__c = (String) formData.get('accountNumber')
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
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:X', 'updateACHNumber');
            ccrz.ccLog.close(result);
        }

        return result;
    }
}