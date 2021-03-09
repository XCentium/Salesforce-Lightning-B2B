({
    getList : function(component, event, helper) {
        var action = component.get("c.todo");
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.ToDos",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
    },
	OpenDialog: function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set('v.selectedTask',whichOne);
        component.set('v.SetCId',whichOne);
        
        var cmpTarget = component.find('TaskModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    CloseDialog: function(component, event, helper) {
        var cmpTarget = component.find('TaskModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
    },
    CompleteTask: function(component, event, helper){
        var currenttask = component.get('v.selectedTask');
        if(currenttask == 1){
            component.set('v.task1done','true');
        }
        if(currenttask == 2){
            component.set('v.task2done','true');
        }
        if(currenttask == 3){
            component.set('v.task3done','true');
        }
        
        var cmpTarget = component.find('TaskModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
    }
})