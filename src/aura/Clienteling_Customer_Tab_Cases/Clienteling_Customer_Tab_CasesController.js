({
	getCases : function(component, event, helper) {
        console.log("Contact ID: " + component.get("v.ContactId"));
		var action = component.get("c.getContactCases");
        action.setParams({
            ContactId : component.get("v.ContactId"),
        });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
                console.log("success");
            	component.set("v.Cases",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    OpenDialog: function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set('v.selectedCase',whichOne);
        component.set('v.overlayClass','slds-backdrop_open');
        
        
        var cmpTarget = component.find('CaseModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');

        $A.createComponent("forceChatter:feed", {"type":"Record", "subjectId": whichOne}, function(feed) {
            var feedContainer = component.find("feedContainer");
            feedContainer.set("v.body", feed);
        });
    },
    CloseDialog: function(component, event, helper) {
        var cmpTarget = component.find('CaseModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        component.set('v.overlayClass','slds-backdrop_closed');
    },
    tabOneAction: function(component, event, helper) {
		var tab1 = component.find('t1');
		var showTab1 = component.find('tab1');

		var tab2 = component.find('t2');
		var showTab2 = component.find('tab2');

		$A.util.addClass(tab1, 'slds-active');
		$A.util.addClass(showTab1, 'slds-show');
		$A.util.removeClass(showTab1, 'slds-hide');

		$A.util.removeClass(tab2, 'slds-active');
		$A.util.removeClass(showTab2, 'slds-show');
		$A.util.addClass(showTab2, 'slds-hide');
      },
    tabTwoAction: function(component, event, helper) {

		var tab1 = component.find('t1');
		var showTab1 = component.find('tab1');

		var tab2 = component.find('t2');
		var showTab2 = component.find('tab2');
        
		$A.util.removeClass(tab1, 'slds-active');
		$A.util.removeClass(showTab1, 'slds-show');
		$A.util.addClass(showTab1, 'slds-hide');

        $A.util.addClass(tab2, 'slds-active');
		$A.util.removeClass(showTab2, 'slds-hide');
		$A.util.addClass(showTab2, 'slds-show');
	}, 
})