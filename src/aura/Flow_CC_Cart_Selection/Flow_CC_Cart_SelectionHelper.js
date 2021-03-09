({
	getCartItems : function(component, event, helper) {
        console.log("Called");
        var callout = component.get("c.getCartItems");
        callout.setParams({
            cartId: component.get("v.CartId")
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            	component.set("v.Items",response.getReturnValue());
                console.log("Items: " + JSON.stringify(response.getReturnValue()));
            }
        });
		$A.enqueueAction(callout);
        
        
        
	},
})