({
    doInit : function(component, event, helper) {
        helper.filterReasons(component);
    },
    confidenceChangeHandler : function(component, event, helper){
        helper.filterReasons(component);
	},
    formatStringChangeHandler : function(component, event, helper){
		let selectedReason = event.getSource().get('v.value');
        console.log(selectedReason);
	},
    deleteReason : function(component, event, helper){
        let deleteReason = component.getEvent("deleteReason");
        deleteReason.setParams({
            index: component.get('v.index')
        })
        deleteReason.fire();
    }
})