({
	getCategories : function(component, event, helper) {
		var action = component.get("c.getMenuCategories");
        action.setParams({
            isFeatured : component.get("v.isFeatured")
        });
		action.setCallback(this, function(response) {
            component.set("v.Categories",response.getReturnValue());
            console.log("Categories: " + JSON.stringify(response.getReturnValue()));
        });
        $A.enqueueAction(action);
	},
	getItems : function(component, event, helper) {
		var action = component.get("c.getMenuItems");
        action.setParams({
            isFeatured : component.get("v.isFeatured")
        });
		action.setCallback(this, function(response) {
        	component.set("v.Items",response.getReturnValue());
        });
        $A.enqueueAction(action);
	}
})