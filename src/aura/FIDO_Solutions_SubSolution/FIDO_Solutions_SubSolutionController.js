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
    toResources : function(component, event, helper) {
        component.set("v.ScreenChoice",'Resources');
        component.set("v.ComponentTitle", "Getting to know your resources");
    },
    toPreviousPage : function(component, event, helper) {
        component.set("v.ScreenChoice",'Personas');
        component.set("v.ComponentTitle", "Getting to know your personas");
    },
    CloseDialog : function(component, event, helper) {
        var cmpTarget = component.find('ScriptModal');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
            
        var cmpTarget2 = component.find('overlay');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
    },
    goToScript : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open(whichOne);
	}
})