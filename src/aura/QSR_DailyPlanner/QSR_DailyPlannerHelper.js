({
	getCurrentDate : function(component, event, helper) {
		var today = new Date();
		var date = today.getDate();
		component.set('v.currentDate', today);
		component.set('v.monthDate', date);

	},

	doSubmitDailyPlanner : function(component, event, helper) {
		var action = component.get("c.createDailyPlanner");
		action.setParams({
			allFMSArrived : component.get("v.allFMSArrived"),
			deploymentChartsPosted : component.get("v.deploymentChartsPosted"),
			shift : component.get("v.shift"),
			weather : component.get("v.weather"),
			transactionActual : component.get("v.transactionActual"),
			transactionGoal : component.get("v.transactionGoal"),
		});
		action.setCallback(this, function(result){
			if(result.getState() === "SUCCESS"){
				console.log('success');
				var res = result.getReturnValue();
				console.log(res);
				var urlEvent = $A.get("e.force:navigateToURL");
				urlEvent.setParams({
				"url": '/'
				});
				urlEvent.fire();
			}
		});
		$A.enqueueAction(action);
	}
})