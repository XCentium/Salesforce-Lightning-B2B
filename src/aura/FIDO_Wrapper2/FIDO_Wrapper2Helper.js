({
    getOrgIndentifier: function(component, event, helper) {
        console.log("Identifying your org...");
        var callout = component.get("c.getOrgIdentifier");
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                /* Get Org Information */
                var org = JSON.stringify(response.getReturnValue());
                org = org.slice(1, -1);
                var endpoint = '/api/orgs?org_identifier__c=' + org;
                var callout2 = component.get("c.getCalloutResponseContents");
                callout2.setParams({
                    endpoint: endpoint
                });
                callout2.setCallback(this, function(response) {
                    var state = response.getState();
                    if(state === 'SUCCESS'){
                        var setid = JSON.parse(response.getReturnValue())[0].sfid;
                        var setname = JSON.parse(response.getReturnValue())[0].name;
                        var setLogo = JSON.parse(response.getReturnValue())[0].gtk_app_logo__c;
                        var setIndustryHeader = JSON.parse(response.getReturnValue())[0].gtk_app_industry_header__c;
                         
                         
                        component.set("v.OrgId",setid);
                        component.set("v.OrgName",setname);
                        component.set("v.appLogo",setLogo);
                        component.set("v.industryHeader",setIndustryHeader);
                        console.log("Identified as " + setname);
                        console.log("Running Complex Algorithms...");
                        
                        component.set("v.Loaded",true);
                    }else{
                        console.log("error");
                    }
                });
                $A.enqueueAction(callout2); 
            }
        });
        $A.enqueueAction(callout); 
    },
    getSettings: function(component, event, helper) {
        var industry = component.get("v.Industry");
        var endpoint
        if (industry != ''){
            endpoint = '/api/settings?industry__c=' + industry;
        }else{
            endpoint = '/api/settings';    
        }
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Settings",JSON.parse(response.getReturnValue()));
                var setupPage = JSON.parse(response.getReturnValue());
                component.set("v.HideSetupPage",setupPage[0].hide_setup_page__c );
            }
        });
        $A.enqueueAction(callout); 
    },
    SetIndustryName: function(component, event, helper) {
        var Industry = component.get("v.Industry");
        var endpoint = '/api/industry?sfid=' + Industry;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
        callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = JSON.parse(response.getReturnValue()); 
                for(var i = 0; i < res.length; i++){
                    component.set("v.IndustryName",res[i].name);
                }
            }else{
                console.log("error")
            }
        });
        $A.enqueueAction(callout);
    },
    showSpinner: function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.removeClass(spinnerMain, "slds-hide");
    },
    
    hideSpinner : function(component) {
        var spinnerMain =  component.find("Spinner");
        $A.util.addClass(spinnerMain, "slds-hide");
    },
})