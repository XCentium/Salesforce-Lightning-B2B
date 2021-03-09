({
	save : function(component, event, helper) {
		component.find("edit").get("e.recordSave").fire();
        component.set('v.show', false);
	},
    
    close : function(component, event, helper) {
        component.set('v.show', false);
    }
})