({
	deleteAssignment : function(component, event, helper) {
		let deleteAssignment = component.getEvent('deleteAssignment');
        let assignment = component.get('v.assignment');
        
        console.log('deleteAssignment', JSON.stringify(assignment,null,2));
        
        deleteAssignment.setParams({
            'payload': assignment
        })
        
        deleteAssignment.fire();
	}
})