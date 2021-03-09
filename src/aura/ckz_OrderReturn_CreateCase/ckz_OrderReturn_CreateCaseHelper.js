({
    generateCase: function(component) {

        console.log('ckz_OrderReturn_CreateCase - generateCase()');

        component.set("v.showSpinner", true);

        var action = component.get("c.createCase");

        action.setParams({
            "orderId" : component.get("v.recordId"),
            "subject" : component.get("v.newCaseSubject"),
            "description" : component.get("v.newCaseDesc"),
            "userName" : component.get("v.caseOwnerName"),
            "selectedItemsString" : component.get("v.selectedItemsString")
        });

        var messages = [];

        action.setCallback(this, function (response) {

            component.set("v.showSpinner", false);

            console.log('back from createCase()');

            var state = response.getState();

             var returnValue = response.getReturnValue();

            if (state === 'SUCCESS') {

                if('caseDataSaved' in returnValue) {
                    if(returnValue.caseDataSaved == true) {
                        component.set("v.isSaved", true);

                        component.set("v.canBack", false);

                        component.set("v.saveMessage", "Return created!")

                        if(returnValue.caseDataSavedMsg) {
                            messages.push({'severity' : 'confirm', 'message' : returnValue.caseDataSavedMsg});
                        }
                    }
                    else {
                        messages.push({'severity' : 'error', 'message' : returnValue.caseDataSavedMsg});
                        component.set("v.hasErrors", true);
                    }
                }

            }
            else {
                console.log('Failed with state: ' + state);

                messages.push({'severity' : 'error', 'message' : returnValue.caseDataSavedMsg});
                component.set("v.hasErrors", true);

            }

            component.set("v.pageMessages", messages);

        });

        $A.enqueueAction(action);

    },
});