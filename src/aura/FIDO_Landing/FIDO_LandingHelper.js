({
    getIndustry: function(component, event, helper) {
        var Industry = component.get("v.Industry");
        var endpoint = '/api/industry?sfid=' + Industry;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.IndustryInfo",JSON.parse(response.getReturnValue()));
            }else{
                console.log("error" );
            }
        });
        $A.enqueueAction(callout); 
    },
    getNews: function(component, event, helper) {
        var orgId = component.get("v.OrgId");
        var endpoint = '/api/announcements?demo_org__c=' + orgId + '&orderby=order__c';
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Announcements",JSON.parse(response.getReturnValue()));
            }else{
                console.log("error: " + orgid);
            }
        });
        $A.enqueueAction(callout); 
    },
	getPersonas: function(component, event, helper) {
        var industry = component.get("v.Industry");
        var endpoint = '/api/persona?industry__c=' + industry;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Personas",JSON.parse(response.getReturnValue()));
            }else{
                console.log("error")
            }
        });
		$A.enqueueAction(callout); 
    },
    getScripts: function(component, event, helper) {
        var industry = component.get("v.Industry");
        var endpoint = '/api/content?industry__c=' + industry;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Scripts",JSON.parse(response.getReturnValue()));
            }else{
                console.log("error")
            }
        });
		$A.enqueueAction(callout); 
    },
    getBrands: function(component, event, helper) {
        var industry = component.get("v.Industry");
        var endpoint = '/api/brands?industry__c=' + industry;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            	component.set("v.Brands",JSON.parse(response.getReturnValue()));
            }
        });
		$A.enqueueAction(callout);
    },
    getCustomizations: function(component, event, helper) {
        var industry = component.get("v.Industry");
        var endpoint = '/api/features?industry__c=' + industry;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Features",JSON.parse(response.getReturnValue()));
            }
        });
		$A.enqueueAction(callout); 
    },
    getResources: function(component, event, helper) {
        var industry = component.get("v.Industry");
        var endpoint = '/api/resource?industry__c=' + industry;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Resources",JSON.parse(response.getReturnValue()));
            }
        });
		$A.enqueueAction(callout); 
    },
    getPartners: function(component, event, helper) {
        var industry = component.get("v.Industry");
        var endpoint = '/api/partners?industry__c=' + industry;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Partners",JSON.parse(response.getReturnValue()));
            }
        });
		$A.enqueueAction(callout); 
    },
})