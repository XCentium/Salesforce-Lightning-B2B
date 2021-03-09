({
	doInit : function(component, event, helper) {
		let didInit = component.get('v.didInit');
        
        if(!didInit){
            let insight = component.get('v.insight');
            console.log(JSON.stringify(insight, null, 2));
            
            helper.getAssignments(component, insight);
            component.set('v.didInit', true);
        }
	},
	lookup : function(component, event, helper) {
        let searchTerm = component.find('searchTerm').get('v.value');
        let isRunning = component.get('v.isRunning');
        
        if(searchTerm.length > 2 && isRunning == false){

            component.set('v.isRunning', true);
            helper.fireAction(component, 'c.getLookup', {
                sobjectType: 'User',
                sobjectField: 'Name',
                searchString: searchTerm
            })
            .then(function(lookups){
                if(helper.VERBOSE) console.log('lookups', lookups);
                component.set('v.lookupValues', lookups);
                component.set('v.showLookup', true);
                component.set('v.isRunning', false);
            })
        }
	},
    handleEvent : function(component, event, helper){
		let eventType = event.getParam('type');
        
        if(eventType == 'lookupSelected'){
            let lookupValue = event.getParam('payload');
            let lookupField = component.get('v.lookupField');
            
            component.set('v.newAssignmentOwner', lookupValue['Id'])
            component.set('v.searchTerm', lookupValue['Name']);
            component.set('v.showLookup', false);
            component.set('v.lookupValues', []);
        }
	},
    insertAssignment: function(component, event, helper){
        let insight = component.get('v.insight');
        let newAssignmentOwner = component.get('v.newAssignmentOwner');
        let insightUserValue = {
            'sobjectType' : 'InsightUserValue',
            'Score': 0.9,
            'InsightId': insight.Id,
            'OwnerId': newAssignmentOwner
        };
        
        if(newAssignmentOwner && newAssignmentOwner != ''){
            helper.fireAction(component, 'c.upsertInsightUserValue', {
                insightUserValue: insightUserValue
            })
            .then(function(){
                return helper.getAssignments(component, insight)
            })
            .then(function(){
                component.set('v.newAssignmentOwner', '')
                component.set('v.searchTerm', '');
            })
        }
    },
    deleteAssignment: function(component, event, helper){
        let deletedInsightUserValue = event.getParam('payload');
        let insight = component.get('v.insight');
        
        deletedInsightUserValue['sobjectType'] = 'InsightUserValue';
        
        helper.fireAction(component, 'c.deleteRecord', {
            record: deletedInsightUserValue
        })
        .then(function(){
            return helper.getAssignments(component, insight)
        })
    }
})