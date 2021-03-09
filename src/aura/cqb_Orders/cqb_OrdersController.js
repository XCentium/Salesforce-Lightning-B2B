({
    doInit : function(component, event, helper) {
        let action = component.get('c.getOrders');
        
        action.setParams({RecId: component.get('v.recordId')});
        
        action.setCallback(this, function(response) {
            component.set('v.orders', response.getReturnValue());
            console.log(response.getReturnValue());
        });
        
        $A.enqueueAction(action);
    },
    
    goToOrder : function(component, event, helper) {
        let orderId = event.getSource().get("v.title");
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": orderId,
        });
        navEvt.fire();
    },
    goToFlow : function(component, event, helper) {
        let orderId = event.getSource().get("v.title");
        $A.createComponent("lightning:flow",
                           {"aura:id": "Service_Console_Returns_Flow" + orderId.toString(),
                            "onstatuschange": component.getReference("c.statusChange")},
                           function(flowCmp) {
                               var targetCmp = component.find('flowContainer');
                               var body = targetCmp.get("v.body");
                               body.push(flowCmp);
                               targetCmp.set("v.body", body); 
                               let inputVariables = [{ name : "InputOrderId", type : "String", value: orderId }];        
                               flowCmp.startFlow("Service_Console_Returns_Flow", inputVariables);                               
                           });
 		/*let orderId = event.getSource().get("v.title");  
        console.log(orderId);
        let flow = component.find('Service_Console_Returns_Flow');
		let inputVariables = [{ name : "InputOrderId", type : "String", value: orderId }]; 
        $A.util.removeClass(flow, 'slds-hide');        
        flow.startFlow("Service_Console_Returns_Flow", inputVariables);*/             
    },
    
    statusChange : function(component, event, helper) {
        if(event.getParam("status") === "FINISHED") {
            console.log('finished!');
            let aid = event.getSource().getLocalId();
            console.log(aid);
            let flow = component.find(aid);
			//$A.util.addClass(flow, 'slds-hide');            
            flow.destroy();
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'SUCCESS!',
                message: 'Order Successfully Returned',
                duration:' 5000',
                type: 'success',
            });
            toastEvent.fire();
            $A.get('e.force:refreshView').fire(); 
        }
        
    }
})