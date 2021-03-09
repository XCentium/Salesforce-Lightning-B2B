({
    init : function(component, event, helper) {
        var industry = component.get("v.Industry");
        var pid = component.get("v.PartnerId");
        industry = industry.replace(/ /g,"%20");
        var endpoint = '/api/content?demo_partner__c=' + pid;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.DemoScripts",JSON.parse(response.getReturnValue()));
            }
        });
		$A.enqueueAction(callout);
        
        let activeSections = component.get("v.activeSections");
        component.set("v.activeSections",[]);
        
	},
    seeMore : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'Scripts');
    },
    OpenDialog: function(component, event, helper) {
        component.set("v.ScreenChoice",'Scripts');
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.setScriptId",whichOne);
    },
    CloseDialog : function(component, event, helper) {
        var cmpTarget = component.find('ShareModal');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
            
        var cmpTarget2 = component.find('overlay');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
    },
    GoToScript : function(component, event, helper) {
        /* Screen change Last */
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.ScreenChoice",'Scripts'); 
    },
    toContent : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open('/lightning/r/Demo_Content__c/' + whichOne + '/view');
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
})