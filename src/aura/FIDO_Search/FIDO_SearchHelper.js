({
    getContent : function(component, event, helper) {
        var ind = component.get("v.Industry");
        var endpoint = '/api/content?industry__c=' + ind;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.DemoScripts",JSON.parse(response.getReturnValue()));
            	helper.hideSpinner(component, event, helper);
            }else{
                helper.hideSpinner(component, event, helper);
            }
        });
        $A.enqueueAction(callout); 
    },
    getFeaturesbyOrg : function(component, event, helper) {
        var OrgId = component.get("v.OrgId");
        var endpoint = '/api/orgfeatureinfo?demo_org__c=' + OrgId;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.FeatureList",JSON.parse(response.getReturnValue()));
            	helper.hideSpinner(component, event, helper);
            }else{
                helper.hideSpinner(component, event, helper);
            }
        });
        $A.enqueueAction(callout); 
        
    },
    getPartners : function(component, event, helper) {
        var ind = component.get("v.Industry");
        var endpoint = '/api/partners?industry__c=' + ind;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Partners",JSON.parse(response.getReturnValue()));
            	helper.hideSpinner(component, event, helper);
            }else{
                helper.hideSpinner(component, event, helper);
            }
        });
        $A.enqueueAction(callout); 
    },
    getResources : function(component, event, helper) {
        var ind = component.get("v.Industry");
        var endpoint = '/api/resource?industry__c=' + ind;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Resources",JSON.parse(response.getReturnValue()));
            	helper.hideSpinner(component, event, helper);
            }else{
                helper.hideSpinner(component, event, helper);
            }
        });
        $A.enqueueAction(callout); 
    },
    getCustomizations : function(component, event, helper) {
        var ind = component.get("v.Industry");
        var endpoint = '/api/features?industry__c=' + ind;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Customizations",JSON.parse(response.getReturnValue()));
            	helper.hideSpinner(component, event, helper);
            }else{
                helper.hideSpinner(component, event, helper);
            }      
        });
        $A.enqueueAction(callout); 
    },
    getVideos : function(component, event, helper) {
        var ind = component.get("v.Industry");
        var endpoint = '/api/videos?industry__c=' + ind;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Videos",JSON.parse(response.getReturnValue()));
                helper.hideSpinner(component, event, helper);
            }else{
                helper.hideSpinner(component, event, helper);
            }
            
        });
        $A.enqueueAction(callout); 
    },
    getPersonas : function(component, event, helper) {
        var ind = component.get("v.Industry");
        var endpoint = '/api/persona?industry__c=' + ind;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Personas",JSON.parse(response.getReturnValue()));
            }
        });
        $A.enqueueAction(callout); 
    },
    getAnnouncements : function(component, event, helper) {
        var OrgId = component.get("v.OrgId");
        var endpoint = '/api/announcements?demo_org__c=' + OrgId;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Announcements",JSON.parse(response.getReturnValue()));
            }
        });
        $A.enqueueAction(callout); 
    },
    OpenDialog: function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.setScriptId",whichOne);
        var cmpTarget = component.find('scriptModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    CloseDialog : function(component, event, helper) {
        var cmpTarget = component.find('scriptModal');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
    },
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    hideSpinner : function(component, event, helper) {
        component.set("v.Spinner", false);
    },
})