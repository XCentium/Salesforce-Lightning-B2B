({
	init : function(component, event, helper) {
        var industry = component.get("v.Industry");
        var endpoint = '/api/brand_cases?industry__c=' + industry;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            	component.set("v.Details",JSON.parse(response.getReturnValue()));
            }else{
                console.log("Error");
            }
        });
		$A.enqueueAction(callout);
	},
    
})