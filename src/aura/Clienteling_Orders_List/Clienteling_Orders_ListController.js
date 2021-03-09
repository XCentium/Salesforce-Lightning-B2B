({
	init : function(component, event, helper) {
		var action = component.get("c.getContactOrders");
        action.setParams({
            ContactId : component.get("v.ContactID"),
        });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Order",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    statusChange : function (cmp, event) {
        if (event.getParam('status') === "FINISHED") {
          //Do something
        }
      },
    NewOrder: function(component,event,helper){
        var cmpTarget = component.find('NewOrderModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        component.set('v.overlayClass','slds-backdrop_open');
        
        var flow = component.find("flow");
        var inputVariables = [
          {
            name : 'recordId',
            type : 'String',
            value : component.get("v.ContactID")
          }
        ];
        flow.startFlow("Create_Order_on_Behalf",inputVariables);
    },
    statusChange : function (component, event) {
        if (event.getParam('status') === "FINISHED") {
            
          var action = component.get("c.getContactOrders");
            action.setParams({
                ContactId : component.get("v.ContactID"),
            });
            action.setCallback(this, function(response) {
                var name = response.getState();
                if (name === "SUCCESS") {
                    component.set("v.Order",response.getReturnValue());
                }
            });
            $A.enqueueAction(action);
            
            
          var cmpTarget = component.find('NewOrderModal');
            $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
            $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
            
            var cmpTarget2 = component.find('overlay');
            $A.util.addClass(cmpTarget2, 'slds-backdrop_closed');
            $A.util.removeClass(cmpTarget2, 'slds-backdrop_open');
            
            component.set('v.overlayClass','slds-backdrop_closed');
        }
      },
    CloseNewOrder: function(component,event,helper){
        var cmpTarget = component.find('NewOrderModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        component.set('v.overlayClass','slds-backdrop_closed');
    },
    handleSuccess: function(component, event, helper) {
        console.log('order id is: ' + component.get("v.selectedOrder"))
        var action = component.get("c.getContactOrders");
        action.setParams({
            ContactId : component.get("v.ContactID"),
        });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Order",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        var cmpTarget = component.find('OrderModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        component.set('v.overlayClass','slds-backdrop_closed');
    },
    OpenDialog: function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        component.set('v.selectedOrder',whichOne);
        
        var cmpTarget = component.find('OrderModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-closed');
        
        component.set('v.overlayClass','slds-backdrop_open');
    },
    CloseDialog: function(component, event, helper) {
        var cmpTarget = component.find('OrderModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        component.set('v.overlayClass','slds-backdrop_closed');
    },
    cancelOrder : function(component, event, helper) {
        var whichOne = event.currentTarget.id;
        var action = component.get("c.CancelOrder");
        action.setParams({
            OrderId: whichOne,
            ContactID : component.get("v.ContactID"),
        });
		action.setCallback(this, function(response) {
            var name = response.getState();
            if (name === "SUCCESS") {
            	component.set("v.Order",response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        var cmpTarget = component.find('OrderModal');
        $A.util.addClass(cmpTarget, 'slds-fade-in-closed');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        
        component.set('v.overlayClass','slds-backdrop_closed');
    }
})