({
	select : function(component, event, helper) {
        var appEvent = $A.get("e.c:CatalogSelectProductEvent");
        appEvent.setParams({
            "productId" : component.get('v.data.Id'),
            "sendBackData" : component.get('v.sendBackData')});
        appEvent.fire();
	}
})