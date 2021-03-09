({
    init : function(component, event, helper) {
        var callout = component.get("c.getAPs");
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            	component.set("v.ActionPlans",response.getReturnValue());
            }
        });
		$A.enqueueAction(callout);
	},
	handleClick : function(component, event, helper) {
        helper.showSpinner(component);
        
        var totalVisits = component.get("v.TotalVisits");
        var callout = component.get("c.generateVisits");
        callout.setParams({
            totalVisits: totalVisits,
            AssignedId: component.get("v.AssignedId"), 
            ActionPlan: component.get("v.AssignedAP"),
            RetailStoreId: component.get("v.RetailStoreId")
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
            	component.set("v.Visits",response.getReturnValue());
                
                for(var i = 0; i < res.length; i++){
                    helper.ActionPlans(component, event, helper,res[i].Id);
                }
                
                helper.hideSpinner(component);
            }else{
                console.log("Error");
                helper.hideSpinner(component);
            }
        });
		$A.enqueueAction(callout);
	},
    Refresh : function(component, event, helper) {
        component.set("v.AssignedId",'');
        component.set("v.TotalVisits",'');
        component.set("v.RetailStoreId",'');
        component.set("v.Visits",null );
        component.set("v.AssignedAP",'' ); 
        component.set("v.Step",1);
    },
    Goto2 : function(component, event, helper) {
        component.set("v.Step",2);
    },
    Goto3 : function(component, event, helper) {
        component.set("v.Step",3);
    },
    Goto4 : function(component, event, helper) {
        component.set("v.Step",4);
    },
})