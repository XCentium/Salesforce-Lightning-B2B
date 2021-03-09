({
    initialLoad : function(component) {

        var action = component.get("c.fetchCurrentQuickThemeInfo");

        var recordId = component.get('v.recordId');

        action.setParams({
            "recordId" : recordId
        });

        action.setCallback(this, function (response) {

            var messages = [];

            component.set('v.showSpinner', false);

            var state = response.getState();

            if (state === 'SUCCESS') {

                var returnValue = response.getReturnValue();

                var errorMsg = null;
                
                if(returnValue.errorMsg) {
                    errorMsg = returnValue.errorMsg;
                    messages.push({'severity' : 'error', 'message' : errorMsg});
                }
                else {
    
                    if(returnValue.name) {
                        component.set("v.currentQuickThemeName", returnValue.name);
                    }
    
                }

            }
            else {
                var errorMsg = 'Failed with state: ' + state
                console.log(errorMsg);
                messages.push({'severity' : 'error', 'message' : errorMsg});
            }

            component.set("v.pageMessages", messages);

        });

        $A.enqueueAction(action);        

    },
    doClone: function(component) {
        var currentQuickThemeId = component.get("v.recordId");
        var newQuickThemeName = component.get("v.newQuickThemeName");

        var action = component.get("c.cloneQuickTheme");

        var recordId = component.get('v.recordId');

        action.setParams({
            "currentQuickThemeId" : recordId,
            "newQuickThemeName" : newQuickThemeName
        });

        action.setCallback(this, function (response) {

            var messages = [];

            component.set("v.pageMessages", messages);

            component.set('v.showSpinner', true);

            var state = response.getState();

            if (state === 'SUCCESS') {

                var returnValue = response.getReturnValue();

                var errorMsg = null;
                
                if(returnValue.qtCloneErrMsg) {
                    errorMsg = returnValue.qtCloneErrMsg;
                    messages.push({'severity' : 'error', 'message' : errorMsg});
                }
 
                if(returnValue.qtCloneMsg) {
                    messages.push({'severity' : 'info', 'message' : returnValue.qtCloneMsg});
                }
                
            }
            else {
                var errorMsg = 'Failed with state: ' + state
                console.log(errorMsg);
                messages.push({'severity' : 'error', 'message' : errorMsg});
            }

            component.set("v.pageMessages", messages);

            component.set('v.showSpinner', false);

        });

        $A.enqueueAction(action);     

    }

})