({
	doInit : function(component, event, helper) {
        var action = component.get("c.commurl");
       action.setParams({
           Community: component.get("v.Community")
       });
		action.setCallback(this, function(response) {
            var state = response.getState();
            var returnValue = response.getReturnValue();  
            var Base = 'https://' + returnValue[2] + '/' + returnValue[3] +'/ccrz__HomePage' ;
            console.log("Base: " + Base);
        	window.open(Base,'_top');
        });
		$A.enqueueAction(action);   
	}
})