({
	addProds : function(component, event, helper) {
        var quant = component.get("v.Quantity");
        var oid = component.get("v.OrderId");
        var pid = component.get("v.ProductId");
        
        console.log("Quantity: " + quant);
        console.log("Order ID: " + oid);
        console.log("Product Id: " + pid);
        
		var action = component.get("c.addProduct");
        action.setParams({
            OrderId : component.get("v.OrderId"),
            ProdId : component.get("v.ProductId"),
            Quantity: component.get("v.Quantity")
            
        });
        action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
                component.set("v.Items",response.getReturnValue());
                
                component.set("v.addIcon","utility:check");
                component.set("v.AddProductText",'Product Added!');
                
            }else {
            	console.log('There was a problem : '+response.getError());
        	}
        });
        $A.enqueueAction(action);  
	}, 
})