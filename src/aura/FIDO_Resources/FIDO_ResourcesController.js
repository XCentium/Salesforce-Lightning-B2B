({
	init : function(component, event, helper) {
        helper.showSpinner(component, event, helper);
        var industry = component.get("v.Industry");
        var endpoint = '/api/resource?industry__c=' + industry;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Resources",JSON.parse(response.getReturnValue()));
                helper.hideSpinner(component, event, helper);
            }else{
                helper.hideSpinner(component, event, helper);
            }
        });
		$A.enqueueAction(callout); 
	},
    toURL : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open(whichOne);
    },
    toResources : function(component, event, helper) {
        component.set("v.ScreenChoice",'Home');
    },
    toPreviousPage : function(component, event, helper) {
        component.set("v.ScreenChoice",'Solutions');
        component.set("v.ComponentTitle", "Getting to know your solutions");
    }
})