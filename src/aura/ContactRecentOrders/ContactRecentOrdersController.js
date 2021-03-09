({
	GetProducts : function(component, event, helper) {
        var action = component.get("c.getProducts");
        console.log('Contact ID: ' + component.get("v.recordId"));
        action.setParams({
            ContactID: component.get("v.recordId"),
            lim: component.get("v.lim")
        });
		action.setCallback(this, function(response) {
            console.log("Values: " + response.getReturnValue());
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.ReturnedProduct",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    ViewOrders : function(component, event, helper) {
        var redUrl ="/lightning/r/"+ component.get("v.recordId")+"/related/Orders1__r/view";
        window.open(redUrl);
    }
})