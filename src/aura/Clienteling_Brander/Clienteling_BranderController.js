({
	init : function(component, event, helper) {
       /* Get Record values */
       var action = component.get("c.GetClientelingInfo");
        action.setParams({
            RecId: component.get("v.recordId")
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var settings = response.getReturnValue();
                var values = JSON.stringify(settings);
                
                var stringify = JSON.parse(values);
                for (var i = 0; i < stringify.length; i++) {
                    component.set("v.AppBackgroundColor",stringify[i]['App_background_color__c']);
                    component.set("v.HeaderBackgroundColor",stringify[i]['Hex_Color_Scheme__c']);
                    component.set("v.LogoBackgroundColor",stringify[i]['Logo_Background_Color__c']);
                    component.set("v.PrimaryButtonColor",stringify[i]['Primary_Button_Color__c']);
                    component.set("v.SecondaryButtonColor",stringify[i]['Secondary_Button_Collor__c']);
                }
                 
                component.set("v.ClientelingSettings",settings);
                
            }
        });
		$A.enqueueAction(action); 
        
        /* Get Static Resource Id */
       var action = component.get("c.GetStaticResourceId");
        action.setParams({
            RecId: component.get("v.recordId")
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            	component.set("v.LogoId",response.getReturnValue());
            }
        });
		$A.enqueueAction(action);  
	},
    handleClick : function(component, event, helper) {
        var action = component.get("c.UpdateRecord");
        action.setParams({
            RecId: component.get("v.recordId"),
            AppBackgroundColor: component.get("v.AppBackgroundColor"),
            LogoBackgroundColor: component.get("v.LogoBackgroundColor"),
            HeaderBackgroundColor: component.get("v.HeaderBackgroundColor"),
            PrimaryButtonColor: component.get("v.PrimaryButtonColor"),
            SecondaryButtonColor: component.get("v.SecondaryButtonColor")
        });
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var settings = response.getReturnValue();
                var values = JSON.stringify(settings);
                
                var stringify = JSON.parse(values);
                for (var i = 0; i < stringify.length; i++) {
                    component.set("v.AppBackgroundColor",stringify[i]['App_background_color__c']);
                    component.set("v.HeaderBackgroundColor",stringify[i]['Hex_Color_Scheme__c']);
                    component.set("v.LogoBackgroundColor",stringify[i]['Logo_Background_Color__c']);
                    component.set("v.PrimaryButtonColor",stringify[i]['Primary_Button_Color__c']);
                    component.set("v.SecondaryButtonColor",stringify[i]['Secondary_Button_Collor__c']);
                }   
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Successfully Updated Clienteling App!",
                    "message": "You have successfully updated the branding of the clienteling app."
                });
                toastEvent.fire();
            }
        });
		$A.enqueueAction(action); 
    }
})