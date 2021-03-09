({
	init : function(component, event, helper) {
        var industry = component.get("v.Industry");
        var endpoint = '/api/videos?industry__c=' + industry + '&orderby=order__c';
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Videos",JSON.parse(response.getReturnValue()));
            }
        });
		$A.enqueueAction(callout); 
	},
    toURL : function(component, event, helper) {
        helper.MixpanelCallout(component, event, helper);
        var whichOne = event.currentTarget.id;
        window.open(whichOne);
    },
    toResources : function(component, event, helper) {
        component.set("v.ScreenChoice",'Home');
    },
    toPreviousPage : function(component, event, helper) {
        component.set("v.ScreenChoice",'Solutions');
        component.set("v.ComponentTitle", "Getting to know your solutions");
    },
    DemoScriptFilter: function(component, event, helper) {
        component.set("v.Filter",'Demo Scripts');
    },
    EnablementFilter: function(component, event, helper) {
        component.set("v.Filter",'Enablement Videos');
    },
    SetupFilter: function(component, event, helper) {
        component.set("v.Filter",'Setup Guides');
    },
    HowToFilter: function(component, event, helper) {
        component.set("v.Filter",'How Tos');
    },
    ResetFilters: function(component, event, helper) {
        component.set("v.Filter",'');
    },
    ShareableURL: function(component, event, helper) {
        var ind = component.get("v.Industry");
        var page = component.get("v.ScreenChoice");
        var RecordId = event.currentTarget.id;
        component.set("v.ShareableURL",'/c/KnowtheIDO.app?Industry='+ind+'&ScreenChoice=' + page + '&recid=' + RecordId);
        
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
})