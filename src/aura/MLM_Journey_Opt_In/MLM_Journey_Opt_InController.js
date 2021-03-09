({
	init : function(component, event, helper) {
        /** Get all Journeys **/
        var action = component.get("c.getUserInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.recordId",response.getReturnValue());
                helper.getJourneyInfo(component, event, helper);
            }else{
                console.log("error");
            }
        });
        $A.enqueueAction(action);
	},    
    toggleChange : function(component, event, helper) {
       	var changedOne = event.currentTarget.id;
        console.log("Journey ID: " + changedOne);
        var action = component.get("c.AddtoJourneys");
        action.setParams({ 
            cID: component.get("v.recordId"),
            Journey: changedOne
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Successfully Subscribed to Journey',
                        message: 'You have successfully subscribed to this journey!',
                        duration:' 5000',
                        type: 'success',
                        mode: 'pester'
                    });
                toastEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Unable to add you to the journey.',
                        message: 'Please contact your system administrator.',
                        duration:' 5000',
                        type: 'error',
                        mode: 'pester'
                    });
                toastEvent.fire();
            }
        });
		$A.enqueueAction(action);
    },
    toggleChangeRemove : function(component, event, helper) {
        console.log("called");
       	var changedOne = event.currentTarget.id;
        var action = component.get("c.RemovetoJourneys");
        action.setParams({
            cID: component.get("v.recordId"),
            Journey: changedOne
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Successfully Unsubscribed from Journey',
                        message: 'You have successfully unsubscribed from this journey!',
                        duration:' 5000',
                        type: 'success',
                        mode: 'pester'
                    });
                toastEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Unable to unsubscribe from this journey.',
                        message: 'Please contact your system administrator.',
                        duration:' 5000',
                        type: 'error',
                        mode: 'pester'
                    });
                toastEvent.fire();
            }
        });
		$A.enqueueAction(action);
    }
})