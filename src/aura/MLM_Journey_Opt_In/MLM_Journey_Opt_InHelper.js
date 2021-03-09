({
    getJourneyInfo : function(component, event, helper){
        var action = component.get("c.getAllJourneys");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.journeys",response.getReturnValue());
            }
        });
		$A.enqueueAction(action);    
    },
})