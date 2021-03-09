({
	init : function(component, event, helper) {
		var recordId = component.get("v.myId");
        var callout = component.get("c.getObject");
        callout.setParams({
            recid: recordId
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            	component.set("v.objectType",response.getReturnValue());
            }else{
            }
        });
		$A.enqueueAction(callout);
	},
})