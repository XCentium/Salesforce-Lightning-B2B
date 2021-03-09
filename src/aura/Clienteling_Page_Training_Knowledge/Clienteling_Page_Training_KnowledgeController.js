({
	getKnowledge : function(component, event, helper) {
        let totalResults = component.get('v.TotalResults');
        console.log('total: ' + totalResults);
        var action = component.get("c.getSomeKnowledge");
        action.setParams({  TotalResults : totalResults });
        
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Knowledge",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    handleClick : function(component, event, helper) {
        var searchText = component.get('v.searchText');
        if(searchText != ''){
            var action = component.get("c.getFilteredKnowledge");
            action.setParams({  SearchPhrase : searchText });
            
            action.setCallback(this, function(response) {
                var name = response.getState();
                if (name === "SUCCESS") {
                    component.set("v.Knowledge",response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }else{
            let totalResults = component.get('v.TotalResults');
            console.log('total: ' + totalResults);
            var action = component.get("c.getSomeKnowledge");
            action.setParams({  TotalResults : totalResults });
            
            action.setCallback(this, function(response) {
                var name = response.getState();
                if (name === "SUCCESS") {
                    component.set("v.Knowledge",response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
	},
    OpenDialog: function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        console.log(whichOne);
        component.set('v.SelectedTaskId',whichOne);
        
        var action = component.get("c.getCurrentKnowledge");
        action.setParams({  KnowledgeId : whichOne });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.CurrentKnowledge",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        var cmpTarget = component.find('KnowledgeModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    CloseDialog: function(component, event, helper) {
        var cmpTarget = component.find('KnowledgeModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
    },
})