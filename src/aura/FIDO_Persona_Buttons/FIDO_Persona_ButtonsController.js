({
	init : function(component, event, helper) {
        
        if(component.get("v.recType") == 'User'){
            var action = component.get("c.GetPersonaId");
            action.setParams({
                Name: component.get("v.PersonaName")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    component.set("v.personaId",response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }else if(component.get("v.recType") == 'Contact'){
            var action = component.get("c.GetContactId");
            action.setParams({
                Name: component.get("v.PersonaName")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    component.set("v.personaId",response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
        
		var action2 = component.get("c.GetOrgId");
		action2.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            	component.set("v.OrgId",response.getReturnValue());
            }
        });
		$A.enqueueAction(action2);	
	},
    toUser : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open('/lightning/r/user/' + whichOne + '/view');
    },
    editUser: function(component, event, helper) {
        var cmpTarget = component.find('EditModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    CloseDialog : function(component, event, helper) {
        var cmpTarget = component.find('EditModal');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
            
        var cmpTarget2 = component.find('overlay');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
    },
    handleSubmit : function(component, event, helper) {       
        var cmpTarget = component.find('EditModal');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
            
        var cmpTarget2 = component.find('overlay');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    },
    toContact : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open('/lightning/r/Contact/' + whichOne + '/view');
    },
	ShareableURL: function(component, event, helper) {
        var ind = component.get("v.Industry");
        var page = component.get("v.ScreenChoice");
        var RecordId = event.currentTarget.id;
        component.set("v.ShareableURL",'/c/KnowtheIDO.app?Industry='+ind+'&ScreenChoice=Personas&recid=' + RecordId);
        
        var cmpTarget = component.find('ShareModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    CloseDialog : function(component, event, helper) {
        var cmpTarget = component.find('ShareModal');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
            
        var cmpTarget2 = component.find('overlay');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
    },
    LoginAsUser : function(component, event, helper) {
        var userId = event.currentTarget.id;
        var orgId = component.get("v.OrgId");
        var url = "/servlet/servlet.su?oid=" + orgId + "&retURL=/"; 
        url += "&suorgadminid=" + userId + '&targetURL=%2F';
        
        let mixpanelEvent = component.getEvent('MixpanelEvent');
        mixpanelEvent.setParams({
            eventName: 'SDO Event',
            payload: {
                action: 'Personas - Multi'
            }
        });
        mixpanelEvent.fire();
        window.location.replace(url);
    },
})