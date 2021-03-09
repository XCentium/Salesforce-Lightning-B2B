({
	GetUser : function(component, event, helper) {
		var action = component.get("c.isActiveUser");
		action.setCallback(this, function(response) {
            console.log(response);
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.ActiveUser",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})