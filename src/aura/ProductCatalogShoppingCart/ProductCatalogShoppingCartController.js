({
    doInit : function(component, event, helper) {
        var action = component.get("c.getAccounts");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.accounts", response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
	addToCart : function(component, event, helper) {
		var product = event.getParam("Product");	
		var quantity = event.getParam("Quantity");
        // TODO: add product and quantity to local
        var newItem = {
            product: product,
            quantity: quantity
        };
        helper.addNewItem(component, newItem);
        helper.updateTotal(component);
	},
	showModal : function(component, event, helper) {
        var modal = component.find("modal");
        $A.util.addClass(modal, "slds-fade-in-open");
        var modal = component.find("backdrop");
        $A.util.addClass(modal, "slds-backdrop--open");
	},
    hideModal : function(component, event, helper) {
        var modal = component.find("modal");
        $A.util.removeClass(modal, "slds-fade-in-open");
        var modal = component.find("backdrop");
        $A.util.removeClass(modal, "slds-backdrop--open");
    },
    onAccountChange : function(component, event, helper) {
        var accountId = component.find("account").get("v.value");
        component.set("v.selectedAccount",accountId);
    },
   	createOrder : function(component, event, helper) {
        var accountId = component.get("v.selectedAccount");
        var items = component.get("v.itemsInCart");
        // Lets properly turn this into Line Items
        var lineItems = [];
        items.forEach(function(item){
            var lineItem = {
                sobjectType : "Catalog_Line_Item__c",
                Product__c : item.product.Id,
                Quantity__c : item.quantity
            }
            lineItems.push(lineItem);
        });
        
        var action = component.get("c.createCatalogOrder");
        action.setParams({ accountId : accountId,
                          items : lineItems});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var orderNumber = response.getReturnValue();
                component.set("v.orderNumber",orderNumber);
                helper.removeAllItems(component);
                helper.updateTotal(component);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error("Error message: " +
                                 errors[0].message);
                    }
                } else {
                    console.error("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

//        var modal = component.find("modal");
//        $A.util.removeClass(modal, "slds-fade-in-open");
//        var modal = component.find("backdrop");
//        $A.util.removeClass(modal, "slds-backdrop--open");
    },
    removeItem : function(component, event, helper) {
    	// TODO remove Product record from itemsInCart
        var productId = event.getSource().get("v.class");
        helper.removeItem(component,productId);
        helper.updateTotal(component);
    }
})