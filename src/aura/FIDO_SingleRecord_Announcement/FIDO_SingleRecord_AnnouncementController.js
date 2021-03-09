({
	init : function(component, event, helper) {
		var recid = component.get("v.recid");
		var endpoint = '/api/announcements?id=' + recid ;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Data",JSON.parse(response.getReturnValue()));
                helper.getScripts(component,event,helper);
                helper.getVideos(component,event,helper);
                helper.getCustomizations(component,event,helper);
                helper.getPartners(component,event,helper);
                helper.getOrgFeatures(component,event,helper);
                
                var res = JSON.parse(response.getReturnValue());  
                for(var i = 0; i < res.length; i++){
                    component.set("v.RecordName", res[i].name); 
                }
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
        component.set("v.ShareableURL",'/c/KnowtheIDO.app?Industry='+ind+'&ScreenChoice=Updates&recid=' + RecordId);
        
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
    GoToPartner : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
    },
    GoToScript : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        console.log('1 ' + event.currentTarget.id);
        console.log('2 ' + event.target.id);
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'Scripts');
    },
    seeMore : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'Partners');
    },
    goToCustomization : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'Customizations'); 
    },
    goToOrgFeature : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'Features'); 
    },
})