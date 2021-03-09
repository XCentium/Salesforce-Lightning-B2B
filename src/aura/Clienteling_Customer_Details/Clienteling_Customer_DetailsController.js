({
	init : function(component, event, helper) {
		var action = component.get("c.getContactRecord");
        action.setParams({
            ContactId : component.get("v.ContactID"),
        });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Contact",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})