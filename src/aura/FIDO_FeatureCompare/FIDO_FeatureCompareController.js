({
	init : function(component, event, helper) { 
        helper.showSpinner(component);
        var action = component.get("c.getOrgIdentifier");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.OrgIdentifier",response.getReturnValue());
                helper.getAllFeatures(component, event, helper);
                helper.getDemoorgDetails(component, event, helper);
            }
        });
		$A.enqueueAction(action);
        
        helper.getOrgOptions(component, event, helper);
	},
    handleSetActiveSectionC: function (component, event, helper) {
        var whichOne = event.currentTarget.id;
        var together = whichOne + '-parent';
        var cmpTarget = document.getElementById(together);
        var classCheck = $A.util.hasClass(document.getElementById(together), "slds-is-open");
        if(classCheck == true){
            $A.util.removeClass(cmpTarget, 'slds-is-open');
        }else{
            $A.util.addClass(cmpTarget, 'slds-is-open');
        }
    },
    SearchUpdate : function(component, event, helper) { 
        var action = component.get("c.getOrgIdentifier");
		action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.OrgIdentifier",response.getReturnValue());
                helper.getAllFeatures(component, event, helper);
                helper.getDemoorgDetails(component, event, helper);
            }
        });
		$A.enqueueAction(action);
        
        helper.getOrgOptions(component, event, helper);
        
	},
    onOrgChange: function(component, event, helper) {
        var filter = event.getSource().get("v.value");
        component.set("v.OrgIdentifier2",filter) ;
        helper.getDemoorg2Details(component, event, helper);
    },
    OpenDialog: function(component, event, helper) {
        var cmpTarget = component.find('OrgModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        var cmpTarget2 = component.find('orgcheckoverlay');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_open');
		$A.util.removeClass(cmpTarget2, 'slds-backdrop_closed');
    },
    CloseDialog : function(component, event, helper) {
        var cmpTarget = component.find('OrgModal');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
            
        var cmpTarget2 = component.find('orgcheckoverlay');
        $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
        $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
    },
})