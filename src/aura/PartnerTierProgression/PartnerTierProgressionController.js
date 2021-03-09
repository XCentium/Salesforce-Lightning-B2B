/**
 * Created by cxu on 31/05/2017.
 */
({
    doInit : function (cmp, event, helper) {
		helper.retreivePartnerAccount(cmp);
    },
    handleAccountChange : function (cmp, event, helper) {
        var account = cmp.get("v.account");
        if (account !== null && account.Current_Partner_Level__r.Next_Level__c !== null) {
            helper.initialiseProgressChart(cmp, account);
            helper.retrieveLevelRequirements(cmp, account.Current_Partner_Level__r.Next_Level__c);
        }
    }
    
})