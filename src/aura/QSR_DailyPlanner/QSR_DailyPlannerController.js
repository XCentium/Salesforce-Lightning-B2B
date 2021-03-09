({
	doInit : function(component, event, helper) {
		console.log('init');
		helper.getCurrentDate(component, event, helper);
	},

	doSubmitDailyPlanner : function(component, event, helper) {
		helper.doSubmitDailyPlanner(component, event, helper);
	}
})