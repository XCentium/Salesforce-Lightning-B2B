({
	init : function(component, event, helper) {
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
        
        helper.MixpanelCallout(component, event, helper);
	},
    toPersonas : function(component, event, helper) {
        component.set("v.ScreenChoice",'Personas');
        component.set("v.ComponentTitle", "Getting to know your personas");
    },
    toPreviousPage : function(component, event, helper) {
        component.set("v.ScreenChoice",'Home');
        component.set("v.ComponentTitle", "Getting to know the RCG IDO");
    },
    OpenDialog: function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.ModalSelection",whichOne);
        
        var cmpTarget = component.find('BrandMoreModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('overlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    CloseDialog : function(component, event, helper) {
        component.set("v.ModalSelection",'');
        var cmpTarget = component.find('BrandMoreModal');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
            
        var cmpTarget2 = component.find('overlay');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
    },
    toURL  : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open(whichOne);
    }
})