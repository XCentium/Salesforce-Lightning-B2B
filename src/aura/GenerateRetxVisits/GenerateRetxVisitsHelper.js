({
	showSpinner: function(component) {
		component.set("v.Spinner", true); 
	},
	hideSpinner : function(component) {
		component.set("v.Spinner", false);
	},
    ActionPlans : function(component, event, helper,VisitId) {
        console.log("Visit ID: " + VisitId);
		var callout = component.get("c.createActionPlans");
        callout.setParams({
            VisitId: VisitId,
            ActionPlan: component.get("v.AssignedAP"),
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log("Success");
            }
        });
		$A.enqueueAction(callout);
	},
})