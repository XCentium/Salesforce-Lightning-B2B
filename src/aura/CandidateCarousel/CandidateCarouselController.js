({
	doInit : function(component, event, helper) {
		var action = component.get("c.findAll");
		action.setParams({
            "pageNumber": 1
    	});
        action.setCallback(this, function(a) {
            var result = a.getReturnValue();
            console.log('Applicants List',result);
            component.set("v.applicants", result.applicants);
            component.set("v.totalApplicants", result.total);
        });
        $A.enqueueAction(action);
	},
    nextCandidate: function(component, event, helper) {
		var currentIndex = component.get("v.applicant_displayed")+1;
        component.set("v.applicant_displayed",currentIndex>=component.get("v.totalApplicants")?0:currentIndex);
	},
    previousCandidate: function(component, event, helper) {
		var currentIndex = component.get("v.applicant_displayed")-1;
        component.set("v.applicant_displayed",currentIndex<0?component.get("v.totalApplicants")-1:currentIndex);
	}
})