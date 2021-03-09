({
	init : function(component, event, helper) {
		var action = component.get("c.getIAs");
        console.log(component.get("v.recordId"));
        action.setParams({caseID: component.get("v.recordId")});
        
        action.setCallback(this, function(response){
           component.set("v.iaRecords", response.getReturnValue());
           component.set("v.gotRecord", 'YES!');
           console.log(response.getReturnValue());
           console.log(component.get("v.iaRecords"));
        });
        
        $A.enqueueAction(action);
	}
})