({
	getScripts : function(component, event, helper) {
		var recid = component.get("v.recid");
		var endpoint = '/api/content?demo_announcements__c=' + recid; 
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resp = JSON.parse(response.getReturnValue());
                component.set("v.RelatedScripts",resp);
            }else{
                console.log("error");
            }
        });
		$A.enqueueAction(callout); 
	},
    getPartners : function(component, event, helper) {
		var recid = component.get("v.recid");
		var endpoint = '/api/partners?demo_announcements__c=' + recid; 
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resp = JSON.parse(response.getReturnValue());
                component.set("v.RelatedPartners",resp);
            }else{
                console.log("error");
            }
        });
		$A.enqueueAction(callout); 
	},
    getOrgFeatures : function(component, event, helper) {
		var recid = component.get("v.recid");
		var endpoint = '/api/orgfeatures?demo_announcements__c=' + recid; 
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resp = JSON.parse(response.getReturnValue());
                component.set("v.RelatedOrgFeatures",resp);
            }else{
                console.log("error");
            }
        });
		$A.enqueueAction(callout); 
	},
    getVideos : function(component, event, helper) {
		var recid = component.get("v.recid");
		var endpoint = '/api/videos?demo_announcements__c=' + recid; 
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resp = JSON.parse(response.getReturnValue());
                component.set("v.RelatedVideos",resp);
            }else{
                console.log("error");
            }
        });
		$A.enqueueAction(callout); 
	},
    getCustomizations : function(component, event, helper) {
		var recid = component.get("v.recid");
		var endpoint = '/api/features?demo_announcements__c=' + recid; 
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resp = JSON.parse(response.getReturnValue());
                component.set("v.RelatedCustomizations",resp);
            }else{
                console.log("error");
            }
        });
		$A.enqueueAction(callout); 
	},
    getUserEmail : function(component, event, helper) {
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
        var d = new Date();
		var n = d.toString();
        var domain = window.location.hostname;
        var ret = domain.replace('www.','');
        var ret = domain.replace('.com','');
        let mixpanelEvent = component.getEvent('MixpanelEvent');
        mixpanelEvent.setParams({
            eventName: 'IDO-GetToKnow',
            payload: {
                Page: component.get("v.ScreenChoice"),
                PageID: component.get("v.recid"),
                URL: window.location.href,
                IndustryID: component.get("v.Industry"),
                UserEmail: component.get("v.UserEmail"),
                IndustryName: component.get("v.IndustryName"),
                OrgName: component.get("v.OrgName"),
                RecordName: component.get("v.RecordName"),
                Domain: window.location.hostname,
                DateAccessed: n
            }
        });
        mixpanelEvent.fire();
	},
})