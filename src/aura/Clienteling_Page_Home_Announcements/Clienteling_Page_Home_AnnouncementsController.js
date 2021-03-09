({
	getAnnouncements : function(component, event, helper) {
		var action = component.get("c.getAllAnnouncements");
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.allAnnouncements",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
})