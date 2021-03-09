({
    init: function(component, event, helper) {
        var orgid = component.get("v.OrgId");
        if(orgid != ''){
            var endpoint = '/api/industry?demo_org__c=' + orgid;
            var callout = component.get("c.getCalloutResponseContents");
            callout.setParams({
                endpoint: endpoint
            });
            callout.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    component.set("v.Industries",JSON.parse(response.getReturnValue()));
                }
            });
            $A.enqueueAction(callout);
        }  
	},
    LoadIndustries : function(component, event, helper) {
        var orgid = component.get("v.OrgId");
        var endpoint = '/api/industry?demo_org__c=' + orgid;
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            	component.set("v.Industries",JSON.parse(response.getReturnValue()));
                setTimeout(function () {
                	var cmpTarget = component.find('PoweredLogo');
        			$A.util.removeClass(cmpTarget, 'hide');
                }, 1000);
            }
        });
		$A.enqueueAction(callout);
	},
    IndustryChoice: function(component, event, helper) {
        var cmpTarget = component.find('PoweredLogo');
        $A.util.addClass(cmpTarget, 'hide');

    	var whichOne = event.currentTarget.id;
        
        var endpoint = '/api/industry?sfid=' + whichOne;
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
                
            	component.set("v.Industries",JSON.parse(response.getReturnValue()));
                component.set("v.Industry",whichOne);
            }else{
                console.log("error")
            }
        });
		$A.enqueueAction(callout);
	},
    ShowSubCategories: function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.ParentIndustry",whichOne);
        
        var elements = document.getElementById("sub");
        elements.classList.add("show");
        elements.classList.remove("hide");
		
        var elements2 = document.getElementById(whichOne);
        elements2.classList.add("hide");
        elements2.classList.remove("show");
	},
})