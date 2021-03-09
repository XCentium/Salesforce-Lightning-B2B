({
	getAdminUserName : function(component, event, helper) {
		var callout = component.get("c.GetAdminUserName");
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue(); 
                component.set("v.UserName",res);
            }else{
                console.log("error")
            }
        });
        $A.enqueueAction(callout);
	},
    getAdminUserEmail : function(component, event, helper) {
		var callout = component.get("c.GetAdminUserEmail");
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue(); 
                component.set("v.UserEmail",res);
                $A.enqueueAction(callout);
            }else{
                console.log("error")
            }
        });
        $A.enqueueAction(callout);
	},
    MixPanelCallout : function(component, event, helper) {
        var callout = component.get("c.GetAdminUserEmail");
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue(); 
                component.set("v.UserEmail",res);
                helper.MixpanelCallout(component, event, helper);
            }else{
                console.log("error")
            }
        });
        $A.enqueueAction(callout);
        
	},
    
    MixpanelCallout : function(component, event, helper) {
        /** Pass data to MixPanel **/
        let mixpanelEvent = component.getEvent('MixpanelEvent');
        mixpanelEvent.setParams({
            eventName: 'IDO-GetToKnow',
            payload: {
                Page: component.get("v.ScreenChoice"),
                PageID: component.get("v.recid"),
                URL: window.location.href,
                IndustryID: component.get("v.Industry"),
                UserEmail: component.get("v.UserEmail")
            }
        });
        mixpanelEvent.fire();
	}
    
})