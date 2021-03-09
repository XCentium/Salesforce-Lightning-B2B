({
	init : function(component, event, helper) {
        /* Get Opt In Value by Journey ID */
		var action = component.get("c.CheckJourneyOptIn");
        action.setParams({
            cID: component.get("v.cID"),
            journeyid: component.get("v.journeyid"),
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.optCount",response.getReturnValue());
            }
        });
		$A.enqueueAction(action);
        
        /* Get Journey Details */
		var action2 = component.get("c.getJourneyDetails");
        action2.setParams({
            jId: component.get("v.journeyid"),
        });
		action2.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.journeyDetails",response.getReturnValue());
            }
        });
		$A.enqueueAction(action2);
        
        /* Get Opt In Value by Journey ID */
		var action3 = component.get("c.ContactJourneyOptIn");
        action3.setParams({
            cID: component.get("v.cID"),
            journeyid: component.get("v.journeyid"),
        });
		action3.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.OptIns",response.getReturnValue());
            }
        });
		$A.enqueueAction(action3);
        
        
	},
})