({
	init : function(component, event, helper) {
		var recid = component.get("v.recid");
		var endpoint = '/api/content?id=' + recid ;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Data",JSON.parse(response.getReturnValue()));
                var resp = JSON.parse(response.getReturnValue());
                for(var i = 0; i < resp.length; i++){
                    component.set("v.ScriptId",resp[i].sfid);
                    component.set("v.RecordName", resp[i].name); 
                }
                helper.getScriptVideos(component,event,helper);
                helper.getScriptFeatures(component, event, helper);
                helper.getScriptCustomizations(component, event, helper);
                helper.getScriptPersonas(component,event,helper);
                helper.getScriptLicenses(component,event,helper);
                helper.getUserEmail(component,event,helper);
                
            }else{
                console.log("error");
            }
        });
		$A.enqueueAction(callout); 
        
        
	},
    back: function(component, event, helper) {
        component.set("v.recid",'');
    }, 
    ShareableURL: function(component, event, helper) {
        var ind = component.get("v.Industry");
        var page = component.get("v.ScreenChoice");
        var RecordId = event.currentTarget.id;
        component.set("v.ShareableURL",'/c/KnowtheIDO.app?Industry='+ind+'&ScreenChoice=Scripts&recid=' + RecordId);
        
        var cmpTarget = component.find('ShareModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    CloseDialog : function(component, event, helper) {
        var cmpTarget = component.find('ShareModal');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
            
        var cmpTarget2 = component.find('overlay');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
    },
    toURL : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open(whichOne);
    },
    goToOrgFeature : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'Features'); 
    },
    goToCustomization : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'Customizations'); 
    },
})