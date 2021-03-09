({
    doInit : function(component, event, helper) {
		helper.loadCurrentMilestones(component);
    },
    doGetAllMilestones : function(component, event, helper) {
    	helper.loadAllMilestones(component);
    },
    doGetCurrentMilestones : function(component, event, helper) {
    	helper.loadCurrentMilestones(component);
    },
    //Delimiter for future code
})