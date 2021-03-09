({
	init : function(component, event, helper) {
		var action = component.get("c.getContactWishlist");
        action.setParams({
            ContactId : component.get("v.ContactID"),
        });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Wishlist",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
})