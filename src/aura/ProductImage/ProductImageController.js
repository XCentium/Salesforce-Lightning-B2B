({
	init : function(component, event, helper) {
        var ccId = component.get("v.recordId");
		var action = component.get("c.getCCProduct");
        action.setParams({  ProdId : ccId });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.ccProduct",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    handleClick : function(component, event, helper) {
        var ccId = component.get("v.ccProduct");
		 window.open('/lightning/r/ccrz__E_Product__c/' + ccId + '/view');
	}
})