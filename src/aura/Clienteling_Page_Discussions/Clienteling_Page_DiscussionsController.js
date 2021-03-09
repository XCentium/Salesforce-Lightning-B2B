({
	init : function(component, event, helper) {
		var action = component.get("c.getUnansweredDiscussions");
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Discussions",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    OpenDialog : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        var action = component.get("c.getCurrentDiscussion");
        action.setParams({  DiscussionId : whichOne });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.SelectedDiscussion",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        var getDiscussionIdaction = component.get("c.getCurrentDiscussionId");
        getDiscussionIdaction.setParams({  DiscussionId : whichOne });
		getDiscussionIdaction.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.SelectedDiscussionId",response.getReturnValue());
            }
        });
        $A.enqueueAction(getDiscussionIdaction);
		        
        var cmpTarget = component.find('DiscussionModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    CloseDialog: function(component, event, helper) {
        var cmpTarget = component.find('DiscussionModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
    },
    AddComment : function(component, event, helper) {
        var comment = component.find('NewCommentValue').get('v.value');
        var dId = component.get('v.SelectedDiscussionId');
        var action = component.get("c.addDiscussionComment");
        action.setParams({  
            DiscussionId : dId,
            comment : comment
        });
		action.setCallback(this, function(response) {
            console.log('response is: ' + response);
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.SelectedDiscussion",response.getReturnValue());
            }
            else if (name === "INCOMPLETE") {
                console.log('Incomplete');
            }
            else if (name === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);       
    },
    updateValue : function(component, event, helper) {
        var searchInput = component.find("NewCommentValue");
    	var searchValue = searchInput.get("v.value");
        component.set('v.NewCommentValue',searchValue); 
    }
})