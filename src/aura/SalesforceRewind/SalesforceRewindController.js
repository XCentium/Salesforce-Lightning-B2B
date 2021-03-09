({
    onInit : function(component, event, helper) {
        component.set('v.subscription', null);
        // Register error listener for the empApi component.
        const empApi = component.find('empApi');
        // Error handler function that prints the error to the console.
        const errorHandler = function (message) {
            console.error('Received error ', JSON.stringify(message));
        };
        // Register error listener and pass in the error handler function.
        empApi.onError($A.getCallback(errorHandler));
        helper.subscribe(component, event, helper);       
        helper.getCustomSetting(component);
        helper.getRewindRecords(component);
    },
     
    onDelete : function(component, event, helper) {
        helper.onDelete(component, event, helper);
    },
    
    onDeleteAll : function(component, event, helper) {
        helper.onDeleteAll(component, event, helper);
    },
    
    onRewind : function(component, event, helper) {     
        helper.onRewind(component, event, helper);
    },
    
    onRewindAll : function(component, event, helper) {
        helper.onRewindAll(component, event, helper);
    },
    
    startRecording : function(component, event, helper) {
        helper.setRecording(component, true);
    },
    
    stopRecording : function(component, event, helper) {
        helper.setRecording(component, false);
    },
    
    showhelp : function(component, event, helper) {
        component.set("v.showhelp", !component.get("v.showhelp"));
    },
})