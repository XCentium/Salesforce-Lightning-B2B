({
	getDemoorgDetails : function(component, event, helper) {
		var orgiden = component.get("v.OrgIdentifier");

        /* Get Demo org Info */ 
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: '/api/orgs?org_identifier__c='+ orgiden
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = JSON.parse(response.getReturnValue()); 
                for(var i = 0; i < res.length; i++){
                    component.set("v.DemoOrg", res[i].sfid); 
                    component.set("v.OrgName", res[i].name);
                }
                
                helper.getOrgFeatures(component, event, helper);
                var org2 = component.get("v.DemoOrg2");
                
            }
        });
		$A.enqueueAction(callout); 
	},
    getDemoorg2Details : function(component, event, helper) {
		var orgiden = component.get("v.OrgIdentifier2");
        
        /* Get Demo org Info */ 
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: '/api/orgs?org_identifier__c='+ orgiden
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = JSON.parse(response.getReturnValue()); 
                for(var i = 0; i < res.length; i++){
                    component.set("v.DemoOrg2", res[i].sfid); 
                    component.set("v.Org2Name", res[i].name); 
                }
				helper.getComparedOrgFeatures(component, event, helper);
            }
        });
		$A.enqueueAction(callout); 
	},
    getOrgFeatures : function(component, event, helper) {
        var demoOrg = component.get("v.DemoOrg");
        /* Get Org Features */
        var callout2 = component.get("c.getCalloutResponseContents");
        callout2.setParams({
            endpoint: '/api/orgfeatureinfo?demo_org__c=' + demoOrg
        });
		callout2.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.OrgFeatures",JSON.parse(response.getReturnValue()));
                helper.hideSpinner(component);
            }else{
                helper.hideSpinner(component);
            }
        });
		$A.enqueueAction(callout2); 
	},
    getComparedOrgFeatures : function(component, event, helper) {
        var demoOrg2 = component.get("v.DemoOrg2");
        /* Get Org 2 Features */
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: '/api/orgfeatureinfo?demo_org__c=' + demoOrg2
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Org2Features",JSON.parse(response.getReturnValue()));
                helper.hideSpinner(component);
            }else{
                helper.hideSpinner(component);
            }
        });
		$A.enqueueAction(callout); 
	},
    
    getOrgOptions : function(component, event, helper) {
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: '/api/orgs'
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.orgOptions",JSON.parse(response.getReturnValue()));
            }else{
                console.log("error");
            }
        });
		$A.enqueueAction(callout); 
     },
    getAllFeatures : function(component, event, helper) {
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: '/api/orgfeatures'
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Features",JSON.parse(response.getReturnValue()));
            }
        });
		$A.enqueueAction(callout); 
     },
    showSpinner: function(component) {
		component.set("v.Spinner", true); 
	},
	hideSpinner : function(component) {
		component.set("v.Spinner", false);
	},
    
    
})