({
	init : function(component, event, helper) {
		var action = component.get("c.getNewProducts");
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Products",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
})