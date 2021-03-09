({
	init : function(component, event, helper) {
        
        /** Get retail Store ID **/
        var callout = component.get("c.getRetailStoreId");
        callout.setParams({
            recid: component.get("v.recordId")
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            	component.set("v.StoreId",response.getReturnValue());
            }
        });
		$A.enqueueAction(callout);
        
        /** Get Available Action Plans **/
        var callout = component.get("c.getAPs");
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
            	component.set("v.ActionPlans",response.getReturnValue());
            }
        });
		$A.enqueueAction(callout);
        
        /** Get todays date **/
        var today = new Date();
        var dd = String(today.getDate() + 1).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        
        today = yyyy + '-' + mm + '-' + dd;
        
        component.set("v.todaysDate",today);
	},
    createVisit : function(component, event, helper) {
        /** Create the Visit **/
        var callout = component.get("c.CreateVisit");
        callout.setParams({
            AssignedId: component.get("v.AssignedId"),
            ActionPlan: component.get("v.AssignedAP"),
            RetailStoreId: component.get("v.StoreId"),
            visitDate: component.get("v.VisitTime"),
            instructions: component.get("v.instructions")
        });
		callout.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var res = response.getReturnValue();
            	component.set("v.Visits",response.getReturnValue());
                
                helper.ActionPlans(component, event, helper,res[0].Id);
                helper.hideSpinner(component);
            }else{
                onsole.log("Error in creating visit");
                helper.hideSpinner(component);
            }
        });
		$A.enqueueAction(callout);
    },
    closeQuickAction : function(component, event, helper) {
        /** Close Quick Action **/
        $A.get("e.force:closeQuickAction").fire();
    }
    
})