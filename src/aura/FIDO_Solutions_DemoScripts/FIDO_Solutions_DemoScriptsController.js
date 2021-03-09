({
	init : function(component, event, helper) {
        helper.showSpinner(component);
		var sid = component.get("v.SolutionId");
        var endpoint = '/api/content?demo_solution__c=' + sid + '&orderby=order__c';
        var callout = component.get("c.getCalloutResponseContents");
        callout.setParams({
            endpoint: endpoint
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.DemoScripts",JSON.parse(response.getReturnValue()));
                helper.hideSpinner(component);
            }else{
                helper.hideSpinner(component);
                console.log("error getting demo scripts");
            }
        });
		$A.enqueueAction(callout); 
	},
    OpenDialog: function(component, event, helper) {
        component.set("v.ScreenChoice",'Scripts');
        var whichOne = event.currentTarget.id;
        component.set("v.recid",whichOne);
        component.set("v.setScriptId",whichOne);
    },
    CloseDialog : function(component, event, helper) {
        var cmpTarget = component.find('scriptModal');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
            
        var cmpTarget2 = component.find('overlay');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
    },
    toScript : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open(whichOne);
    },
    toContent : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open('/lightning/r/Demo_Content__c/' + whichOne + '/view');
    },
})