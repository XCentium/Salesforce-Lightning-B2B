({
    doInit : function(component, event, helper) {
        // Get a reference to the function defined in the Apex controller
        var action = component.get("c.getNetworks");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        
        // Register the callback function
        action.setCallback(this, function(res) {
            let state = res.getState();
            let data = res.getReturnValue();
            if(state === 'SUCCESS'){
                console.log('CommunityLoginController:init:success', data);
            }
            else if(state === 'ERROR'){
                console.log('CommunityLoginController:init:error', res.getError());
            }
            
            if(data){
                component.set("v.orgId", data.orgId);
                component.set("v.networks", data.networks);
                component.set("v.loginUser", data.loginUser);
            }
        });
        
        // Invoke the service
        $A.enqueueAction(action);
    },
    
    openCommunity : function(component, event, helper){
        
        let mixpanelEvent = component.getEvent('MixpanelEvent');
        console.log('mixpanelEvent',mixpanelEvent);
        mixpanelEvent.setParams({
            eventName: 'SDO Event',
            payload: {
                action: 'Community Login',
            }
        });
        
        mixpanelEvent.fire();
        
        var orgId = component.get("v.orgId");
        var recordId = component.get("v.recordId");
        var loginUser = component.get("v.loginUser.Id");
        var network = event.getSource().get('v.name');
        
        var url = "/servlet/servlet.su?oid=" + orgId + "&retURL=/" + recordId + "&sunetworkuserid="+ loginUser + "&sunetworkid=" + network;
        
        window.location.href = url;
    }
})