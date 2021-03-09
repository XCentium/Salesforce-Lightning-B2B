({
	init : function(component, event, helper) {
		var industry = component.get("v.Industry");
        industry = industry.replace(/ /g,"%20");
        var endpoint = '/api/solution?industry__c=' + industry + '&orderby=order__c';
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Solutions",JSON.parse(response.getReturnValue()));
            }
        });
		$A.enqueueAction(callout); 
	},
    goToURL : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open(whichOne);
	},
    handleSetActiveSectionC: function (component, event, helper) {
        var whichOne = event.currentTarget.id;
        var together = whichOne + '_parent';
        var cmpTarget = document.getElementById(together);
        var classCheck = $A.util.hasClass(document.getElementById(together), "slds-is-open");
        if(classCheck == true){
            $A.util.removeClass(cmpTarget, 'slds-is-open');
        }else{
            $A.util.addClass(cmpTarget, 'slds-is-open');
        }
    },
})