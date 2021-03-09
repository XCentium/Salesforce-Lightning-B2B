/**
 * Created by cxu on 31/05/2017.
 */
({
    doInit : function(cmp, event, helper) {
        var action = cmp.get("c.getPartnerAccount");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var account = response.getReturnValue();
                if (account != null) {
                    cmp.set("v.account", account);
                    if (account.Current_Partner_Level__r !== null) {
                        cmp.set("v.levelIcon", account.Current_Partner_Level__r.Icon_URL__c);
                    }
                }
            }
            else if (state === "INCOMPLETE") {
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " +
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    }
})