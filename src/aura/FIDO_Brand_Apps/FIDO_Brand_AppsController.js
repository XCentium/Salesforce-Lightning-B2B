({
	init : function(component, event, helper) {
		var industry = component.get("v.Industry");
        var endpoint = '/api/brand_app?industry__c=' + industry;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            	component.set("v.Apps",JSON.parse(response.getReturnValue()));
            }
        });
		$A.enqueueAction(callout);
	},
    GoToApps : function(component, event, helper) {
        window.open('/lightning/setup/NavigationMenus/home');
    }
})