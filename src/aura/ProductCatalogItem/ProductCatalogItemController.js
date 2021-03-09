({
	showModalLightning : function(component, event, helper) {
        var modal = component.find("modal");
        $A.util.addClass(modal, "slds-fade-in-open");
        var modal = component.find("backdrop");
        $A.util.addClass(modal, "slds-backdrop--open");
	},
    hideModalLightning : function(component, event, helper) {
        var modal = component.find("modal");
        $A.util.removeClass(modal, "slds-fade-in-open");
        var modal = component.find("backdrop");
        $A.util.removeClass(modal, "slds-backdrop--open");
    },
    addToCartLightning : function(component, event, helper) {
        var appEvent = $A.get("e.c:ProductCatalogAddToCart");
        appEvent.setParams({
            "Product" : component.get("v.product"),
            "Quantity" : component.get("v.quantity")
        });
        appEvent.fire();

        var modal = component.find("modal");
        $A.util.removeClass(modal, "slds-fade-in-open");
        var modal = component.find("backdrop");
        $A.util.removeClass(modal, "slds-backdrop--open");
    },
})