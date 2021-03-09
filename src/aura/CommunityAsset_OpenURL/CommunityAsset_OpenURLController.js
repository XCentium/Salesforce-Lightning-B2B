({
    doInit: function(component, event, helper) {
        window.open("/AlpinePartner/s/iot-commerce");
        var a = component.get('c.closeDialog');
        $A.enqueueAction(a);
    },
    closeDialog : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
})