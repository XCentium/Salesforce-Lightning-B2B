({
	getTasks : function(component, event, helper) {
		var action = component.get("c.getUserTasks");
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.allTasks",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
;	},
    NewTask: function(component, event, helper) {
        var cmpTarget = component.find('NewTaskModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    OpenTaskDialog: function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        console.log(whichOne);
        component.set('v.SelectedTaskId',whichOne);
        
        var action = component.get("c.getTaskInfo");
        action.setParams({  TaskId : whichOne });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.currentTask",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        var cmpTarget = component.find('ViewTaskModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    SaveTask: function(component, event, helper) {
        /*Updated Task */
        let currentTaskId = component.get('v.SelectedTaskId');
        var action = component.get("c.updateTask");
        action.setParams({  
            TaskId : currentTaskId ,
            Subject: 'test',
            Status: 'Completed'
        });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
                console.log('successfully updated');
            	component.set("v.allTasks",response.getReturnValue());
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Account Widget was created."
                });
                toastEvent.fire();
                
                var cmpTarget = component.find('ViewTaskModal');
                $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
                $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
                
                var cmpTarget2 = component.find('overlay');
                $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
                $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
                
            }else if (name === "ERROR") {
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
    CloseDialog: function(component, event, helper) {
        var cmpTarget = component.find('ViewTaskModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
    },
    OpenTask: function(component,event,helper){
        var whichOne = event.currentTarget.id;
        console.log(whichOne);
    }
})