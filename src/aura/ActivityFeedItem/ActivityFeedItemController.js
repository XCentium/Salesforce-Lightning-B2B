({
    navToActivity : function(component, event, helper) {
        var id = component.get('v.id');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": id,
          "slideDevName": "details"

        });
        navEvt.fire();
        console.log('navigated to activity: ' + id);
		
	},
    editActivity : function(component, event, helper) {
    var editRecordEvent = $A.get("e.force:editRecord");
    editRecordEvent.setParams({
         "recordId": component.get("v.id")
   });
    editRecordEvent.fire();
}
})