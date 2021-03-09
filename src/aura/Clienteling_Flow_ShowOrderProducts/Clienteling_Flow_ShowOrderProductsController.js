({
	init : function(component, event, helper) {
        var action = component.get("c.getOrderProducts");
        action.setParams({
            oId : component.get("v.OrderId"),
        });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Products",response.getReturnValue());
                
            }else{
                console.log("err0r");
            }
        });
        $A.enqueueAction(action);
        
        var orderaction = component.get("c.getOrderInfo");
        orderaction.setParams({
            oId : component.get("v.OrderId"),
        });
		orderaction.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") { 
            	component.set("v.Order",response.getReturnValue());
            }else{
                console.log("Error");
            }
        });
        $A.enqueueAction(orderaction);
	},
    removeProds : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        var action = component.get("c.removeProduct");
        action.setParams({
            OrderId : component.get("v.OrderId"),
            ProdId : whichOne,
        });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Products",response.getReturnValue());
				console.log("Products: " + JSON.stringify(response.getReturnValue()));
            }else{
                console.log("Error");
            }
        });
        $A.enqueueAction(action);
        
        var orderaction = component.get("c.getOrderInfo");
        orderaction.setParams({
            oId : component.get("v.OrderId"),
        });
		orderaction.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") { 
            	component.set("v.Order",response.getReturnValue());
            }
        });
        $A.enqueueAction(orderaction);
    },
    handleNavigate: function(cmp, event) {
       var navigate = cmp.get("v.navigateFlow");
       navigate(event.getParam("action"));
    }
})