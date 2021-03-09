({	
    handleQuantityChange : function(component, event, helper) {
        if(component.get("v.Quantity") > 0){
            helper.addProds(component, event, helper);
        }
    }
})