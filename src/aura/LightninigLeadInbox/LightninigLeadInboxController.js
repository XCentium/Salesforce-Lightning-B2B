({
	doInit: function(component) {
        var action = component.get("c.getOpenLead"); // method in the apex class
        action.setCallback(this, function(a) {
            component.set("v.opens", a.getReturnValue()); // variable in the component
        })
        $A.enqueueAction(action);
    
    },
    updateRecord : function(component, event) {
        var ownerid = event.target.getAttribute('data-vOwnerId');
        var leadId = event.target.getAttribute('data-vLeadId');
        
        var updateRecordAction = component.get("c.updateLeadRecord");
        updateRecordAction.setParams({"leadId" : leadId, "ownerId" : ownerid});
        updateRecordAction.setCallback(this, function(a) {
            console.log('Record updated!');
            component.set("v.opens", a.getReturnValue());
        });
        $A.enqueueAction(updateRecordAction);
    }
        
})