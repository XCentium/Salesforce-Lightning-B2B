({
    init : function(component, event, helper) {
        var action = component.get("c.CheckPermSet");
        action.setParams({
            PermName: component.get("v.PermissionSetApiName")
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.isAdded",response.getReturnValue());
            }
        });
		$A.enqueueAction(action);
	}, 
	toggleChange:function(component,event,helper){
        var currVal = component.get("v.isAdded");
        if(currVal != true){
            var action = component.get("c.AddPermissionSetToAdmin");
            action.setParams({
                PermName: component.get("v.PermissionSetApiName")
            });
            action.setCallback(this, function(response) {
                var name = response.getState();
                if (name === "SUCCESS") {
                    component.set("v.isAdded",true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success Added Permissions!",
                        "type" : 'Success',
                        "message": "You have successfully added these permissions to your Admin User."
                    });
                    toastEvent.fire();
                }else{
                    console.log("Error")
                }
            });
            $A.enqueueAction(action);
        }else{
            var action = component.get("c.RemovePermissionSetToAdmin");
            action.setParams({
                PermName: component.get("v.PermissionSetApiName")
            });
            action.setCallback(this, function(response) {
                var name = response.getState();
                if (name === "SUCCESS") {
                    component.set("v.isAdded",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success Removed Permissions!",
                        "message": "You have successfully removed these permissions from your Admin User."
                    });
                    toastEvent.fire();
                }else{
                    console.log("Error")
                }
            });
            $A.enqueueAction(action);
        }
    },
    openActionWindow : function(component, event, helper) {
		 window.open(component.get("v.ExternalUrl"));
	}
})