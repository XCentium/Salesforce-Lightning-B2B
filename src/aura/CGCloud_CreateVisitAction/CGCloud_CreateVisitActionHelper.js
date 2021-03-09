({
	showSpinner: function(component) {
		component.set("v.Spinner", true); 
	},
	hideSpinner : function(component) {
		component.set("v.Spinner", false);
	},
    ActionPlans : function(component, event, helper,VisitId) {
        console.log("Action Plans called with: " + VisitId);
        console.log("Visit ID: " + VisitId);
        console.log("Action Plan: " + component.get("v.AssignedAP"));
		var callout = component.get("c.createActionPlans");
        callout.setParams({
            VisitId: VisitId,
            ActionPlan: component.get("v.AssignedAP"),
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log("Success");
            }else{
                console.log("Error");
            }
        });
		$A.enqueueAction(callout);
	},
})