({
    getSettings: function(component, event, helper) {
        var industry = component.get("v.Industry");
        var endpoint;
        if (industry != ''){
            endpoint = '/api/settings?industry__c=' + industry;
        }else{
        	endpoint = '/api/settings';    
        }
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Settings",JSON.parse(response.getReturnValue()));
                var setupPage = JSON.parse(response.getReturnValue());
                component.set("v.HideSetupPage",setupPage[0].hide_setup_page__c );                
            }
        });
		$A.enqueueAction(callout); 
    },
    
})