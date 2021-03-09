({
	totalStepsChange : function(component, event, helper) {
		var totalSteps = component.get("v.totalSteps");
        var steps = [];
        for (var i = 0; i < totalSteps; i++) {
            steps.push(i);
        }
        component.set("v.steps", steps);
	}
})