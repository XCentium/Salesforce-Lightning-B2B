({
    init : function(component, event, helper) {
        var callout = component.get("c.accountAlerts");
        callout.setParams({
            recid: component.get("v.recordId")
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.Alerts",response.getReturnValue());
                console.log('*** ' + response.getReturnValue());
            }else{
                console.log("Intelligent Alerts: Query Error")
            }
        });
		$A.enqueueAction(callout); 
	},
    closeModal:function(component,event,helper){    
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
        
        
    },
    statusChange : function (cmp, event) {
        if (event.getParam('status') === "FINISHED") {
            var flow = component.find("flow");
            flow.destroy();
            var cmpTarget = cmp.find('Modalbox');
            var cmpBack = cmp.find('Modalbackdrop');
            $A.util.removeClass(cmpBack,'slds-backdrop--open');
            $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
        }
  	},
    openmodal: function(component,event,helper) {
        var whichOne = event.currentTarget.id;
        component.set("v.selectedAlert",whichOne);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open'); 
        $A.createComponent("lightning:flow",
            {
                "aura:id": "flow"
            },
        	 function(flowcmp, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(flowcmp);
                    component.set("v.body", body);
                    var flow = component.find("flow");
    				flow.startFlow("Opportunity_Creation_Flow");
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }                  
        );

       
    },
    launchQuickAction :function(component,event,helper) {
        console.log('hello');
    	var actionAPI = cmp.find("quickActionAPI");
        var args = { actionName : "Account.Create_Opportunity", 
                     entityName : "Account"};
        actionAPI.setActionFieldValues(args).then(function() {
            actionAPI.invokeAction(args);
        }).catch(function(e) {
            console.error(e.errors);
        });
  
	}

})