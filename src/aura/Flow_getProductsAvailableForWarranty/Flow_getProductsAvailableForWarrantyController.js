({
    GetProducts : function(component, event, helper) {
        var oid = component.get("v.OrderId");
        var cid = component.get("v.ContactId");
        
            var action = component.get("c.getOrderWarrantyProduct");
            action.setParams({
                cid: cid
            });
            action.setCallback(this, function(response) {
                var name = response.getState();
                if (name === "SUCCESS") {
                    component.set("v.ReturnedProduct",response.getReturnValue());
                    console.log("Order Products: " + JSON.stringify(response.getReturnValue()));
                }else{
                    console.log("Order Error");
                }
            });
            $A.enqueueAction(action);
        
	},
	onSelect : function(component, event) {
        /* Remove Selected Class from previous element if it exists */
		var PreviousCard = component.get("v.PreviousCard"); 
        if(PreviousCard != ""){
            document.getElementById(PreviousCard).classList.remove("selected");
        }
        /* Selected product adds selected class to element */
        var ProductName = event.currentTarget.getAttribute("data-value");
        var ProductID = event.currentTarget.getAttribute("id");
        var d = document.getElementById(ProductID);
		d.className += " selected";
        component.set("v.selectedCard", ProductName);
        component.set("v.PreviousCard", ProductID);
        component.set("v.OrderItemId", ProductID);
        $A.util.addClass(ProductID, 'selected');
        /*$Label.flowProductID = "1234";*/
	}
})