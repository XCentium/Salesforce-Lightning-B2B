({
	assignInsight : function(component, event, helper) {
		let assignInsight = component.getEvent('assignInsight');
        let insight = component.get('v.insight');
        
        console.log('EMC_ExistingInsightController:assignInsight',JSON.stringify(insight, null, 2));
        
        assignInsight.setParams({
            'type': 'assignInsight',
            'payload': insight
        })
        
        assignInsight.fire();
	},
	editInsight : function(component, event, helper) {
		let editInsightEvent = component.getEvent('editInsight');
        let insight = component.get('v.insight');
        
        editInsightEvent.setParams({
            'type': 'editInsight',
            'payload': insight
        })
        
        editInsightEvent.fire();
	},
	deleteInsight : function(component, event, helper) {
		let deleteInsightEvent = component.getEvent('deleteInsight');
        let insight = component.get('v.insight');
        let index = component.get('v.index');
        
        deleteInsightEvent.setParams({
            'type': 'deleteInsight',
            'payload': insight,
            'index': index
        })
        
        deleteInsightEvent.fire();
	}
})