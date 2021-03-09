({
	init : function(component, event, helper) {
		var industry = component.get("v.Industry");
        var endpoint = '/api/brand_community?industry__c=' + industry;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            	component.set("v.Communities",JSON.parse(response.getReturnValue()));
            }
        });
		$A.enqueueAction(callout);
	},
    GoToCommunities : function(component, event, helper) {
        window.open('/lightning/setup/SetupNetworks/home');
    }
})