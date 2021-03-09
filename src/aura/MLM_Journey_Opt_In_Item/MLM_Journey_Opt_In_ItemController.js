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
        
        /* Get Opt In Value by Journey ID */
		var GetContactaction = component.get("c.GetOptInContacts");
        GetContactaction.setParams({
            cID: component.get("v.cID"),
            journeyid: component.get("v.journeyid")
        });
		GetContactaction.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.AvailableContacts",response.getReturnValue());
            }
        });
		$A.enqueueAction(GetContactaction);
	},
    toggleChange : function(component, event, helper) {
        /*if Enabled Toggle, add opt in record */
       	var changedOne = event.currentTarget.id;
        console.log("Journey ID: " + changedOne);
        var action = component.get("c.AddtoJourneys");
        action.setParams({
            cID: component.get("v.cID"),
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
        /* If toggle disabled, delete opt in record */
        console.log("called");
       	var changedOne = event.currentTarget.id;
        var action = component.get("c.RemovetoJourneys");
        action.setParams({
            cID: component.get("v.cID"),
            Journey: changedOne
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("called'")
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
    },
    OpenDialog: function(component, event, helper) {
        var cmpTarget = component.find('AddModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    CloseDialog : function(component, event, helper) {
        var cmpTarget = component.find('AddModal');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
            
        var cmpTarget2 = component.find('overlay');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
    },
    addContact: function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        
        /* Get Opt In Value by Journey ID */
		var GetContactaction = component.get("c.CommunityAddToJourney");
        GetContactaction.setParams({
            cID: whichOne,
            journeyid: component.get("v.journeyid")
        });
		GetContactaction.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.AvailableContacts",response.getReturnValue());
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Successfully Added Contact to Journey',
                        message: 'You have successfully Opt in this contact.',
                        duration:' 5000',
                        type: 'success',
                        mode: 'pester'
                    });
                toastEvent.fire();
            }
        });
		$A.enqueueAction(GetContactaction);
    },
})