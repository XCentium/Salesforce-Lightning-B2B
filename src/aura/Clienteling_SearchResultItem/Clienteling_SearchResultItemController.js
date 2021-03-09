({
	gotoContact : function(component, event, helper) {
        var target = event.target;
    	var rowId = target.getAttribute("id");
        component.set("v.SelectedContact", rowId);
	}
})