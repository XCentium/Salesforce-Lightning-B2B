({
	init : function(component, event, helper) {

        var callout = component.get("c.getStoreOffers");
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log("Offers: " + response.getReturnValue());
                component.set("v.Offers",response.getReturnValue());
            }
        });
		$A.enqueueAction(callout); 
	},
})