/**
 * Created by scheck on 11/5/18.
 */

({
    handleNewDebit: function (args) {
        console.log('qtc_QuickDebitHelper | handleNewDebit');
        let [component, event, helper] = args;

        var toastEvent = $A.get("e.force:showToast");
        var urlEvent = $A.get("e.force:navigateToURL");

        component.set("v.showSpinner", true);


        var action = component.get("c.saveDebit");
        action.setParams({
            "invoiceId": component.get("v.recordId"),
            "totalAmount": component.get("v.totalAmount"),
        });

        action.setCallback(this, function (response) {
            let data = response.getReturnValue();
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log('Success');

                setTimeout(function () {
                    component.set("v.showSpinner", false);
                }, 1500);

                toastEvent.setParams({
                    "title": "Success",
                    "message": "Debit Created!",
                    "type": "success"
                });
                toastEvent.fire();

                var redirect = component.get("v.redirect");
                console.log(redirect);
                if (redirect == true) {
                    urlEvent.setParams({
                        "url": "/one/one.app#/alohaRedirect/apex/blng__debitNoteLineAllocation?scontrolCaching=1&id=" + response.getReturnValue()
                    });

                    urlEvent.fire();
                }

            } else {
                console.log('Failure');

                setTimeout(function () {
                    component.set("v.showSpinner", false);
                }, 1500);

                toastEvent.setParams({
                    "title": "Error",
                    "message": "Error creating Debit!",
                    "type": "error"
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    },

})