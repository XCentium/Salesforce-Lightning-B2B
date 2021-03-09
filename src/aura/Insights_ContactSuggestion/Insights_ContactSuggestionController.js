({
	handleSelect : function(component, event, helper) {
        let selected = event.getParam("value");
        let recordId = component.get('v.recordId');
        let contactSuggestion = component.get('v.contactSuggestion');
        
        switch(selected){
            case 'edit':
                component
                .getEvent('renderPanel')
                .setParams({
                    type : 'c:Insights_EditContactSuggestion',
                    attributes : {
                        contactSuggestion: contactSuggestion,
                        recordId: recordId
                    }
                })
                .fire();
                
                break;
            case 'activate':
                helper.activate(component)
                .then(function(){
                    helper.goToState(component, {
                        type : 'c:Insights_AccountInsights',
                        attributes : {
                            recordId: recordId
                        }
                    })
                })
                
                break;
            case 'assign':
                component
                .getEvent('renderPanel')
                .setParams({
                    type : 'c:Insights_AssignInsight',
                    attributes : {
                        insightId: contactSuggestion.Id,
                        insightType: 'Contact_Suggestion_Insight',
                        insightTitle: contactSuggestion.Title,
                        recordId: recordId
                    }
                })
                .fire();
                
                break;
            case 'delete':
                helper
                .sendRequest(component, 'c.deleteRecord', { 
                        sobjectName: 'ContactSuggestionInsight',
                        recordId: contactSuggestion.Id
                    }
                )
                .then(function(){
                    helper.showToast(component, {
                        message: 'Contact Suggestion Successfully Deleted',
                        type: 'success'
                    });
                })
                .then(function(){
                    component.destroy()
                })
            default:
                return false;
                break;
        }
	}
})