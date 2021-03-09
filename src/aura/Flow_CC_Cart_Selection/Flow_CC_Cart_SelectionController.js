({
	init : function(component, event, helper) {
        console.log("Contact ID: " + component.get("v.ContactId"));
        var callout = component.get("c.getCCCart");
        callout.setParams({
            ContactId: component.get("v.ContactId")
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resp = response.getReturnValue();
                component.set("v.CartId",resp[0].Id);
            	component.set("v.Carts",response.getReturnValue());
                helper.getCartItems(component, event, helper);
            }
        });
		$A.enqueueAction(callout);
	},
})