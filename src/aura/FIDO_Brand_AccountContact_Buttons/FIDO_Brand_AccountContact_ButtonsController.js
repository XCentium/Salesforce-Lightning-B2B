({
	init : function(component, event, helper) {
        var con = component.get("v.contactname");
        var acc = component.get("v.accountname");
        var lead = component.get("v.leadname");
        var casename = component.get("v.casename");
        var opp = component.get("v.oppname");
        
        if(con != ''){
            var action = component.get("c.GetContactId");
            action.setParams({
                Name: con
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    component.set("v.recId",response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
        if(acc != ''){
            var action = component.get("c.lookupAccount");
            action.setParams({
                Name: acc
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    component.set("v.recId",response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
        if(lead != ''){
            var action = component.get("c.lookupLead");
            action.setParams({
                Name: lead
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    component.set("v.recId",response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
        if(casename != ''){
            var action = component.get("c.lookupCase");
            action.setParams({
                Name: casename
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    component.set("v.recId",response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
        if(opp != ''){
            var action = component.get("c.lookupOpportunity");
            action.setParams({
                Name: opp
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === 'SUCCESS'){
                    component.set("v.recId",response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
        
		
	},
    toAccount : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        window.open('/lightning/r/Account/' + whichOne + '/view');
    },
})